import SwiftUI

struct CameraCaptureView: View {
    @ObservedObject var store: AppStore
    let delivery: Delivery
    @Environment(\.presentationMode) var presentationMode
    
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
                        Text("LAT: 12.9716° N  LON: 77.5946° E")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 6, height: 6)
                        Text("GPS STRONG")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
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
    
    func performCapture() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            isAnalyzing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let proof = Proof(
                photoId: UUID().uuidString,
                timestamp: Date(),
                latitude: 12.9716,
                longitude: 77.5946,
                orientation: "Portrait",
                motionData: "Stable",
                accuracy: 4.5
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
