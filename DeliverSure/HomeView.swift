import SwiftUI

struct HomeView: View {
    @ObservedObject var store: AppStore
    
    var body: some View {
        NavigationView {
            ZStack {
                DSColor.background.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(Date(), style: .date)
                                    .font(DSTypography.caption)
                                    .textCase(.uppercase)
                                    .foregroundColor(DSColor.textSecondary)
                                Text("Hello, \(store.driver.name)")
                                    .font(DSTypography.titleLarge)
                                    .foregroundColor(DSColor.textPrimary)
                            }
                            Spacer()
                            Circle()
                                .fill(DSColor.border)
                                .frame(width: 40, height: 40)
                                .overlay(Text("RK").font(.caption).bold())
                        }
                        
                        // Connectivity Status Card
                        HStack {
                            Image(systemName: store.isOnline ? "wifi" : "wifi.slash")
                            Text(store.isOnline ? "Online & Syncing" : "No Internet Connection")
                                .font(DSTypography.bodyBold)
                            Spacer()
                        }
                        .padding()
                        .background(store.isOnline ? DSColor.successBackground : DSColor.warningBackground)
                        .foregroundColor(store.isOnline ? DSColor.success : DSColor.warning)
                        .cornerRadius(12)
                    }
                    .padding(20)
                    .background(DSColor.cardBackground)
                    .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 5)
                    
                    // List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(store.deliveries) { delivery in
                                NavigationLink(
                                    destination: DeliveryDetailView(store: store, deliveryId: delivery.id),
                                    tag: delivery.id,
                                    selection: $store.activeDeliveryId
                                ) {
                                    DeliveryCard(delivery: delivery)
                                }
                            }

                        }
                        .padding(20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct DeliveryCard: View {
    let delivery: Delivery
    
    var statusColor: Color {
        Color(hex: delivery.state.progressColorHex)
    }
    
    var statusIcon: String {
        switch delivery.state {
        case .created: return "circle"
        case .proofCollected: return "camera.fill"
        case .sealed: return "lock.fill"
        case .queued, .uploading, .acknowledged: return "arrow.triangle.2.circlepath"
        case .committed: return "checkmark.circle.fill"
        case .failedRetryable: return "exclamationmark.triangle.fill"
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left Status Stripe/Icon
            VStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.system(size: 20))
                Spacer()
                Rectangle()
                    .fill(statusColor.opacity(0.3))
                    .frame(width: 2)
            }
            .frame(width: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(delivery.expectedWindow)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColor.textSecondary)
                    Spacer()
                    Text(delivery.state.uiDescription.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.1))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                }
                
                Text(delivery.customerName)
                    .font(DSTypography.bodyBold)
                    .foregroundColor(DSColor.textPrimary)
                
                Text(delivery.address)
                    .font(DSTypography.body)
                    .foregroundColor(DSColor.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(DSColor.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: AppStore())
    }
}
