import Foundation
import CoreLocation
import CoreMotion
import Combine
import UIKit

struct SensorSnapshot {
    let location: CLLocation?
    let activity: String
    let orientation: String
    let accuracy: Double
    let timestamp: Date
}

class SensorManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Published State
    @Published var locationString: String = "Locating..."
    @Published var signalStrength: SignalStrength = .weak
    @Published var currentActivity: String = "Stationary"
    @Published var currentOrientation: String = "Portrait"
    
    enum SignalStrength {
        case weak, moderate, strong
    }
    
    // MARK: - Managers
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionActivityManager()
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        setupLocation()
        setupMotion()
        setupOrientation()
    }
    
    // MARK: - Snapshot
    func captureSnapshot() -> SensorSnapshot {
        return SensorSnapshot(
            location: lastLocation,
            activity: currentActivity,
            orientation: currentOrientation,
            accuracy: lastLocation?.horizontalAccuracy ?? -1,
            timestamp: Date()
        )
    }
    
    // MARK: - Location
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        
        // Format: "LAT: 12.9716° N LON: 77.5946° E"
        let lat = String(format: "%.4f", abs(location.coordinate.latitude))
        let lon = String(format: "%.4f", abs(location.coordinate.longitude))
        let latDir = location.coordinate.latitude >= 0 ? "N" : "S"
        let lonDir = location.coordinate.longitude >= 0 ? "E" : "W"
        
        DispatchQueue.main.async {
            self.locationString = "LAT: \(lat)° \(latDir)  LON: \(lon)° \(lonDir)"
            
            // Signal Strength based on horizontal accuracy
            if location.horizontalAccuracy < 10 {
                self.signalStrength = .strong
            } else if location.horizontalAccuracy < 50 {
                self.signalStrength = .moderate
            } else {
                self.signalStrength = .weak
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[SensorManager] Location error: \(error)")
    }
    
    // MARK: - Motion (Walking Detection)
    private func setupMotion() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            self.currentActivity = "Stationary (Simulated)"
            return
        }
        
        motionManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self = self, let activity = activity else { return }
            
            if activity.walking { self.currentActivity = "Walking to Door" }
            else if activity.running { self.currentActivity = "Running" }
            else if activity.automotive { self.currentActivity = "Driving" }
            else if activity.stationary { self.currentActivity = "Stationary" }
            else { self.currentActivity = "Unknown" }
        }
    }
    
    // MARK: - Orientation
    private func setupOrientation() {
        // Observe Device Orientation
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateOrientation()
        }
        updateOrientation()
    }
    
    private func updateOrientation() {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait: self.currentOrientation = "Portrait"
        case .portraitUpsideDown: self.currentOrientation = "Portrait Upside Down"
        case .landscapeLeft: self.currentOrientation = "Landscape Left"
        case .landscapeRight: self.currentOrientation = "Landscape Right"
        case .faceUp: self.currentOrientation = "Face Up"
        case .faceDown: self.currentOrientation = "Face Down"
        default: self.currentOrientation = "Unknown"
        }
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        motionManager.stopActivityUpdates()
    }
}
