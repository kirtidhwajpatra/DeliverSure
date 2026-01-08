import Foundation
import Combine

enum NetworkError: Error {
    case noConnection
    case serverError
    case timeout
}

class NetworkService {
    // Simulates idempotency: Key -> Response Code
    private var idempotencyCache: [String: Int] = [:]
    
    // Simulate network latency & reliability
    func execute(action: DeliveryAction) -> AnyPublisher<Int, Error> {
        let delay = Double.random(in: 0.5...2.0)
        
        return Future<Int, Error> { [weak self] promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                guard let self = self else { return }
                
                // 1. Simulate Network Failure (randomly 10% fail)
                if Double.random(in: 0...1) < 0.1 {
                    promise(.failure(NetworkError.serverError))
                    return
                }
                
                // 2. Idempotency Check
                let key = action.id.uuidString
                if let cachedCode = self.idempotencyCache[key] {
                    print("[Network] Idempotent hit for key: \(key)")
                    promise(.success(cachedCode))
                    return
                }
                
                // 3. Process Action (Simulated)
                print("[Network] Processing action: \(action.type.rawValue) for \(action.deliveryId)")
                self.idempotencyCache[key] = 200
                promise(.success(200))
            }
        }
        .eraseToAnyPublisher()
    }
}
