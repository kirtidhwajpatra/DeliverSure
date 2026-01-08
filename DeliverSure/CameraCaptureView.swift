import SwiftUI
import CoreLocation

struct CameraCaptureView: View {
    @ObservedObject var store: AppStore
    let delivery: Delivery
    @Environment(\.presentationMode) var presentationMode
    
    // Real Sensors
    @StateObject private var sensorManager = SensorManager()
    
    @State private var isAnalyzing = false
    @State private var showSealedScreen = false
    
    var body: some View {
        ZStack {
            // Mock Camera Feed
            Color.black.edgesIgnoringSafeArea(.all)
            
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                Image(systemName: "box.truck.badge.clock.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .foregroundColor(.white.opacity(0.2))
            }
            .edgesIgnoringSafeArea(.all)
            
            // HUD
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Date(), style: .time)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Text(sensorManager.locationString)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                        Text(sensorManager.currentActivity.uppercased()) // Motion Status
                             .font(.system(size: 10, weight: .bold, design: .monospaced))
                             .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Circle()
                            .fill(gpsColor)
                            .frame(width: 6, height: 6)
                        Text(gpsText)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(gpsColor)
                    }
                    .padding(6)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(4)
                }
                .padding(.top, 50)
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Align package in frame")
                        .font(DSTypography.bodyBold)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(20)
                    
                    Button(action: performCapture) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .fill(isAnalyzing ? DSColor.success : Color.white)
                                .frame(width: 66, height: 66)
                                .scaleEffect(isAnalyzing ? 0.9 : 1.0)
                        }
                    }
                    .disabled(isAnalyzing)
                }
                .padding(.bottom, 50)
            }
            
            if isAnalyzing {
                Color.white.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.2), value: isAnalyzing)
            }
            
            // Navigate to sealed
            NavigationLink(destination: ProofSealedView(store: store, delivery: delivery), isActive: $showSealedScreen) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
    }
    
    var gpsColor: Color {
        switch sensorManager.signalStrength {
        case .strong: return .green
        case .moderate: return .orange
        case .weak: return .red
        }
    }
    
    var gpsText: String {
        switch sensorManager.signalStrength {
        case .strong: return "GPS STRONG"
        case .moderate: return "GPS WEAK"
        case .weak: return "NO GPS"
        }
    }
    
    func performCapture() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            isAnalyzing = true
        }
        
        let snapshot = sensorManager.captureSnapshot()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let proof = Proof(
                photoId: UUID().uuidString,
                timestamp: snapshot.timestamp,
                latitude: snapshot.location?.coordinate.latitude ?? 0.0,
                longitude: snapshot.location?.coordinate.longitude ?? 0.0,
                orientation: snapshot.orientation,
                motionData: snapshot.activity,
                accuracy: snapshot.accuracy
            )
            
            // Transition: CREATED -> PROOF_COLLECTED
            store.captureProof(for: delivery.id, proof: proof)
            
            showSealedScreen = true
            isAnalyzing = false
        }
    }
}

struct CameraCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CameraCaptureView(store: AppStore(), delivery: Delivery.mock())
    }
}
