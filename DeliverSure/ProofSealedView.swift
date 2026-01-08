import SwiftUI
import Combine

struct ProofSealedView: View {
    @ObservedObject var store: AppStore
    let delivery: Delivery
    @Environment(\.presentationMode) var presentationMode
    
    // Auto-dismiss after delay
    @State private var timeRemaining = 3
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            DSColor.successBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Animated Checkmark
                ZStack {
                    Circle()
                        .fill(DSColor.success)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: DSColor.success.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 10) {
                    Text("Delivery Secured")
                        .font(DSTypography.titleLarge)
                        .foregroundColor(DSColor.textPrimary)
                    
                    Text("Sync will happen automatically.")
                        .font(DSTypography.body)
                        .foregroundColor(DSColor.textSecondary)
                }
                
                Spacer()
                
                Text("Dismissing in \(timeRemaining)s...")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColor.textSecondary.opacity(0.7))
                    .padding(.bottom, 20)
                
                PrimaryButton("Done") {
                    // Manual dismissal
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                         // Dismiss logic handled by parent or manual action in prototype
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Trigger State Transition: PROOF_COLLECTED -> SEALED -> QUEUED
            if delivery.state == .proofCollected {
                store.sealDelivery(for: delivery.id)
            }
        }
    }
}

struct ProofSealedView_Previews: PreviewProvider {
    static var previews: some View {
        ProofSealedView(store: AppStore(), delivery: Delivery.mock())
    }
}
