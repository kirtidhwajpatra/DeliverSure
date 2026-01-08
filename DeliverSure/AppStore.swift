import SwiftUI
import Combine

class AppStore: ObservableObject {
    // MARK: - Published State
    @Published var deliveries: [Delivery] = []
    // Network Monitoring
    private let networkMonitor = NetworkMonitor()
    @Published private(set) var isOnline: Bool = true
    
    // Navigation State
    @Published var activeDeliveryId: String? = nil
    
    // The Brain
    private let syncEngine: SyncEngine
    private var cancellables = Set<AnyCancellable>()
    
    // Driver Context
    let driver = Driver(id: "D-8821", name: "Rahul Kumar", vehicleId: "MH-12-AB-1234")
    
    init() {
        // Initialize Brain
        let queue = ActionQueue()
        let network = NetworkService()
        self.syncEngine = SyncEngine(queue: queue, network: network)
        
        seedData()
        
        // Bind Network Monitor
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isOnline, on: self)
            .store(in: &cancellables)
            
        // Sync Engine Connectivity binding
        $isOnline
            .sink { [weak self] online in
                print("[AppStore] Real Network Connectivity: \(online)")
                self?.syncEngine.isOnline = online
            }
            .store(in: &cancellables)
        
        // Bind Brain State to UI
        syncEngine.$processedDeliveryIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updates in
                self?.applyBrainUpdates(updates)
            }
            .store(in: &cancellables)
            
        syncEngine.start()
    }
    
    // MARK: - Actions (Forward to Brain)
    
    func resetNavigation() {
        activeDeliveryId = nil
    }
    
    func captureProof(for deliveryId: String, proof: Proof) {
        // Optimistic UI Update: CREATED -> PROOF_COLLECTED
        updateLocalState(for: deliveryId, to: .proofCollected, proof: proof)
        
        // Queue Action
        let data = try? JSONEncoder().encode(proof)
        syncEngine.enqueue(type: .captureProof, deliveryId: deliveryId, payload: data)
    }
    
    func sealDelivery(for deliveryId: String) {
        // Optimistic UI Update: PROOF_COLLECTED -> SEALED -> QUEUED
        updateLocalState(for: deliveryId, to: .sealed)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            // Implicit UI transition to "Saving..."
            self?.updateLocalState(for: deliveryId, to: .queued)
        }
        
        // Queue Action
        syncEngine.enqueue(type: .sealDelivery, deliveryId: deliveryId)
    }
    
    // MARK: - Internal Logic
    
    private func applyBrainUpdates(_ updates: [String: DeliveryState]) {
        for (id, state) in updates {
            print("[AppStore] Brain Update: \(id) -> \(state)")
            updateLocalState(for: id, to: state)
        }
    }
    
    private func updateLocalState(for deliveryId: String, to newState: DeliveryState, proof: Proof? = nil) {
        if let index = deliveries.firstIndex(where: { $0.id == deliveryId }) {
            var delivery = deliveries[index]
            delivery.state = newState
            if let p = proof {
                delivery.proof = p
                delivery.timestamp = Date()
            }
            deliveries[index] = delivery
        }
    }
    
    private func seedData() {
        self.deliveries = [
            Delivery(
                id: "DEL-881",
                customerName: "Siddharth Gupta",
                address: "Flat 401, Galaxy Heights",
                instructions: "Ring doorbell twice.",
                expectedWindow: "10:00 - 12:00",
                state: .created
            ),
            Delivery(
                id: "DEL-882",
                customerName: "Aisha Khan",
                address: "Villa 22, Palm Meadows",
                instructions: "Security guard has key.",
                expectedWindow: "12:30 - 14:00",
                state: .created
            ),
            Delivery(
                id: "DEL-883",
                customerName: "Tech Corp Inc.",
                address: "Office 102, Indiranagar",
                instructions: "Reception desk.",
                expectedWindow: "15:00 - 17:00",
                state: .committed // Already done
            )
        ]
    }
}
