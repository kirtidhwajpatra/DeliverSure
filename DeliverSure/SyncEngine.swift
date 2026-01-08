import Foundation
import Combine

class SyncEngine: ObservableObject {
    private let queue: ActionQueue
    private let network: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // Core brain heartbeat
    private let processingQueue = DispatchQueue(label: "com.deliverSure.syncEngine")
    
    // UI State Binding
    @Published var processedDeliveryIds: [String: DeliveryState] = [:]
    @Published var isSyncing = false
    
    // Connectivity
    var isOnline: Bool = true {
        didSet {
            if isOnline { processNext() }
        }
    }
    
    init(queue: ActionQueue, network: NetworkService) {
        self.queue = queue
        self.network = network
        
        setupHeartbeat()
    }
    
    // MARK: - Public API
    
    func enqueue(type: ActionType, deliveryId: String, payload: Data? = nil) {
        let action = DeliveryAction.create(type: type, deliveryId: deliveryId, payload: payload)
        queue.enqueue(action)
        
        // Immediate Trigger
        processNext()
    }
    
    func start() {
        processNext()
    }
    
    // MARK: - Orchestration
    
    private func setupHeartbeat() {
        // Retry Loop (simple 5s timer for demo, real implementations use efficient scheduling)
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.processNext()
            }
            .store(in: &cancellables)
    }
    
    private func processNext() {
        guard isOnline else {
            // Offline - Do nothing
            return
        }
        
        processingQueue.async { [weak self] in
            guard let self = self, self.isOnline else { return }
            
            // 1. Peek
            guard let action = self.queue.peek() else {
                DispatchQueue.main.async { self.isSyncing = false }
                return
            }
            
            // 2. Validate Backoff (Basic Check)
            if action.status == "FAILED_RETRYABLE" {
                // Check backoff time? For demo, we just retry every loop.
            }
            
            DispatchQueue.main.async { self.isSyncing = true }
            
            // 3. Mark Processing (WAL Phase 1)
            self.queue.updateStatus(id: action.id, status: "PROCESSING", attemptIncrement: true)
            
            // 4. Exec Network
            self.network.execute(action: action)
                .receive(on: self.processingQueue)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("[SyncEngine] Failed: \(error)")
                        self.queue.updateStatus(id: action.id, status: "FAILED_RETRYABLE")
                        DispatchQueue.main.async {
                            // If failed, map to UI state (e.g., FAILED_RETRYABLE)
                            // But usually, we keep it as QUEUED/UPLOADING unless it's terminal
                            // For demo visual:
                            self.processedDeliveryIds[action.deliveryId] = .failedRetryable
                            self.isSyncing = false
                        }
                    }
                }, receiveValue: { _ in
                    // 5. Success -> Commit (WAL Phase 3)
                    self.queue.updateStatus(id: action.id, status: "COMMITTED")
                    self.queue.remove(id: action.id)
                    
                    print("[SyncEngine] Committed action \(action.id)")
                    
                    // Update UI State Cache
                    DispatchQueue.main.async {
                        self.processedDeliveryIds[action.deliveryId] = .committed
                        // Recursive call to drain queue
                        self.processNext()
                    }
                })
                .store(in: &self.cancellables)
        }
    }
    
}
