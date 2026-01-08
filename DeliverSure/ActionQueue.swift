import Foundation
import Combine

class ActionQueue: ObservableObject {
    @Published private(set) var actions: [DeliveryAction] = []
    
    private let fileURL: URL
    private let queueQueue = DispatchQueue(label: "com.deliverSure.actionQueue", qos: .utility)
    
    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = documents.appendingPathComponent("action_queue.json")
        restore()
    }
    
    // MARK: - public API
    
    func enqueue(_ action: DeliveryAction) {
        queueQueue.sync {
            actions.append(action)
            persist()
        }
    }
    
    func peek() -> DeliveryAction? {
        queueQueue.sync {
            return actions.first(where: { $0.status != "COMMITTED" })
        }
    }
    
    func updateStatus(id: UUID, status: String, attemptIncrement: Bool = false) {
        queueQueue.sync {
            if let index = actions.firstIndex(where: { $0.id == id }) {
                actions[index].status = status
                if attemptIncrement {
                    actions[index].attemptCount += 1
                }
                persist()
            }
        }
    }
    
    func remove(id: UUID) {
        queueQueue.sync {
            actions.removeAll(where: { $0.id == id })
            persist()
        }
    }
    
    // MARK: - Persistence
    
    private func persist() {
        do {
            let data = try JSONEncoder().encode(actions)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            // In a real app we'd use OSLog here
            print("[ActionQueue] Persisted \(actions.count) actions.")
        } catch {
            print("[ActionQueue] Failed to save queue: \(error)")
        }
    }
    
    private func restore() {
        queueQueue.sync {
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
            do {
                let data = try Data(contentsOf: fileURL)
                actions = try JSONDecoder().decode([DeliveryAction].self, from: data)
                
                // Crash Recovery: Reset PROCESSING to PENDING or FAILED_RETRYABLE
                for i in 0..<actions.count {
                    if actions[i].status == "PROCESSING" {
                        actions[i].status = "FAILED_RETRYABLE" // Assume crash meant failure
                        print("[ActionQueue] Recovered crashed action: \(actions[i].id)")
                    }
                }
                persist() // Save recovered state
            } catch {
                print("[ActionQueue] Failed to load queue: \(error)")
            }
        }
    }
}
