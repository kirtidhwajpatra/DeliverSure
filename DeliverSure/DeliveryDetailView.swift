import SwiftUI

struct DeliveryDetailView: View {
    @ObservedObject var store: AppStore
    let deliveryId: String
    
    @Environment(\.presentationMode) var presentationMode
    
    var delivery: Delivery? {
        store.deliveries.first(where: { $0.id == deliveryId })
    }
    
    var body: some View {
        ZStack {
            DSColor.background.edgesIgnoringSafeArea(.all)
            
            if let delivery = delivery {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(DSColor.textPrimary)
                        }
                        Spacer()
                        Text("Delivery Details")
                            .font(DSTypography.bodyBold)
                            .foregroundColor(DSColor.textPrimary)
                        Spacer()
                        Image(systemName: "arrow.left").opacity(0)
                    }
                    .padding()
                    .background(DSColor.cardBackground)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // Customer Entity
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CUSTOMER")
                                    .font(DSTypography.caption)
                                    .foregroundColor(DSColor.textSecondary)
                                Text(delivery.customerName)
                                    .font(DSTypography.titleMedium)
                                    .foregroundColor(DSColor.textPrimary)
                            }
                            
                            Divider()
                            
                            // Address
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ADDRESS")
                                    .font(DSTypography.caption)
                                    .foregroundColor(DSColor.textSecondary)
                                Text(delivery.address)
                                    .font(DSTypography.titleMedium)
                                    .foregroundColor(DSColor.textPrimary)
                                    .lineSpacing(4)
                            }
                            
                            // Instructions
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(DSColor.primary)
                                    Text("Instructions")
                                        .font(DSTypography.bodyBold)
                                        .foregroundColor(DSColor.primary)
                                }
                                Text(delivery.instructions)
                                    .font(DSTypography.body)
                                    .foregroundColor(DSColor.textPrimary)
                            }
                            .padding(16)
                            .background(DSColor.primaryBackground)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(DSColor.primary.opacity(0.1), lineWidth: 1))
                            
                            // State Indicator (if not simply pending)
                            if delivery.state != .created {
                                HStack {
                                    Image(systemName: delivery.state == .committed ? "checkmark.circle.fill" : "clock.fill")
                                        .foregroundColor(Color(hex: delivery.state.progressColorHex))
                                    Text(delivery.state.uiDescription)
                                        .font(DSTypography.bodyBold)
                                        .foregroundColor(Color(hex: delivery.state.progressColorHex))
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(hex: delivery.state.progressColorHex).opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(20)
                    }
                    
                    // Bottom Action (Exclusive for CREATED state)
                    VStack {
                        if delivery.state == .created || delivery.state == .failedRetryable {
                            NavigationLink(destination: CameraCaptureView(store: store, delivery: delivery)) {
                                HStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 19, weight: .bold))
                                    Text("Capture Delivery Proof")
                                        .font(.system(size: 19, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(DSColor.primary)
                                .cornerRadius(12)
                                .shadow(color: DSColor.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        } else {
                            SecondaryButton(title: "View Proof") {
                                // View proof logic could go here
                            }
                            .disabled(true) // For prototype, just show state
                        }
                    }
                    .padding(20)
                    .background(DSColor.cardBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                }
            } else {
                Text("Delivery not found")
            }
        }
        .navigationBarHidden(true)
    }
}

struct DeliveryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DeliveryDetailView(store: AppStore(), deliveryId: "DEL-881")
    }
}
