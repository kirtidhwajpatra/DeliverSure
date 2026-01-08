import SwiftUI
import Combine

class AppStore: ObservableObject {
    // MARK: - Published State
    @Published var deliveries: [Delivery] = []
    @Published var isOnline: Bool = true {
        didSet {
            if isOnline {
                processQueue()
            }
        }
    }
    
    // Driver Context
    let driver = Driver(id: "D-8821", name: "Rahul Kumar", vehicleId: "MH-12-AB-1234")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        seedData()
        
        // Periodic queue processor (simulating a background job runner)
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.processQueue()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Transitions
    
    func toggleConnectivity() {
        isOnline.toggle()
    }
    
    /// TRANSITION: CREATED -> PROOF_COLLECTED
    func captureProof(for deliveryId: String, proof: Proof) {
        updateState(for: deliveryId, to: .proofCollected) { delivery in
            delivery.proof = proof
            delivery.timestamp = Date()
        }
    }
    
    /// TRANSITION: PROOF_COLLECTED -> SEALED -> QUEUED
    func sealDelivery(for deliveryId: String) {
        // First transitions to SEALED
        updateState(for: deliveryId, to: .sealed)
        
        // Then automatically queues it (implicit queuing requirement #5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.updateState(for: deliveryId, to: .queued)
            self?.processQueue()
        }
    }
    
    // MARK: - Sync Logic (Queue Processing)
    
    private func processQueue() {
        guard isOnline else { return }
        
        let queuedItems = deliveries.filter { $0.state == .queued || $0.state == .failedRetryable }
        
        for item in queuedItems {
            simulateNetworkSync(for: item.id)
        }
    }
    
    private func simulateNetworkSync(for deliveryId: String) {
        // TRANSITION: QUEUED -> UPLOADING
        updateState(for: deliveryId, to: .uploading)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self, self.isOnline else {
                // If went offline during upload
                self?.updateState(for: deliveryId, to: .failedRetryable)
                return
            }
            
            // TRANSITION: UPLOADING -> ACKNOWLEDGED -> COMMITTED
            // We skip explicit 'ACKNOWLEDGED' delay for UI simplicity, jumping to COMMITTED
            self.updateState(for: deliveryId, to: .committed)
        }
    }
    
    // MARK: - Helper
    
    private func updateState(for deliveryId: String, to newState: DeliveryState, modification: ((inout Delivery) -> Void)? = nil) {
        guard let index = deliveries.firstIndex(where: { $0.id == deliveryId }) else { return }
        
        var delivery = deliveries[index]
        delivery.state = newState
        modification?(&delivery)
        deliveries[index] = delivery
    }
    
    // MARK: - Seed Data
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
