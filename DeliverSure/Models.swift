import Foundation
import CoreLocation

// MARK: - State Machine
enum DeliveryState: String, Codable {
    case created = "CREATED"
    case proofCollected = "PROOF_COLLECTED"
    case sealed = "SEALED"
    case queued = "QUEUED"
    case uploading = "UPLOADING"
    case acknowledged = "ACKNOWLEDGED"
    case committed = "COMMITTED"
    case failedRetryable = "FAILED_RETRYABLE"
    
    var uiDescription: String {
        switch self {
        case .created: return "Not started"
        case .proofCollected: return "Proof captured"
        case .sealed: return "Secured"
        case .queued, .uploading, .acknowledged: return "Saving..."
        case .committed: return "Completed"
        case .failedRetryable: return "Will retry automatically"
        }
    }
    
    var progressColorHex: String {
        switch self {
        case .created: return "5E6C84" // Neutral
        case .proofCollected, .sealed: return "0052CC" // Blue (Active)
        case .queued, .uploading, .acknowledged: return "6554C0" // Purple (Syncing)
        case .committed: return "107C41" // Green (Success)
        case .failedRetryable: return "FF991F" // Warning (Amber)
        }
    }
}

enum SyncStatus {
    case online
    case offline
    case syncing
    
    var title: String {
        switch self {
        case .online: return "Online"
        case .offline: return "Offline Mode"
        case .syncing: return "Syncing..."
        }
    }
}

// MARK: - Models
struct Delivery: Identifiable, Codable {
    let id: String
    let customerName: String
    let address: String
    let instructions: String
    let expectedWindow: String
    var state: DeliveryState
    var proof: Proof?
    var timestamp: Date?
    
    static func mock() -> Delivery {
        Delivery(
            id: UUID().uuidString,
            customerName: "Alice Johnson",
            address: "123 Green Park Ave, Block B",
            instructions: "Leave at front desk. Call if locked.",
            expectedWindow: "2:00 PM - 4:00 PM",
            state: .created,
            proof: nil
        )
    }
}

struct Proof: Codable {
    let photoId: String
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let orientation: String
    let motionData: String
    let accuracy: Double
}

struct Driver: Identifiable {
    let id: String
    let name: String
    let vehicleId: String
}

// MARK: - Brain Models
enum ActionType: String, Codable {
    case captureProof = "CAPTURE_PROOF"
    case sealDelivery = "SEAL_DELIVERY"
}

struct DeliveryAction: Identifiable, Codable {
    let id: UUID
    let type: ActionType
    let deliveryId: String
    let payload: Data? // JSON encoded payload (e.g. Proof)
    let createdAt: Date
    var attemptCount: Int
    var status: String // "PENDING", "PROCESSING", "FAILED_RETRYABLE"
    
    static func create(type: ActionType, deliveryId: String, payload: Data? = nil) -> DeliveryAction {
        return DeliveryAction(
            id: UUID(),
            type: type,
            deliveryId: deliveryId,
            payload: payload,
            createdAt: Date(),
            attemptCount: 0,
            status: "PENDING"
        )
    }
}
