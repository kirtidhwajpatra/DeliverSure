import SwiftUI

struct RootView: View {
    @StateObject var store = AppStore()
    
    var body: some View {
        TabView {
            HomeView(store: store)
                .tabItem {
                    Label("My Run", systemImage: "list.bullet.rectangle.portrait.fill")
                }
            
            SyncActivityView(store: store)
                .tabItem {
                    Label("Activity", systemImage: "arrow.triangle.2.circlepath")
                }
            
            DisputeReplayPreviewView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
        .accentColor(DSColor.primary)
    }
}

// Sync Activity View
struct SyncActivityView: View {
    @ObservedObject var store: AppStore
    
    var body: some View {
        ZStack {
            DSColor.background.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Text("Sync Activity")
                        .font(DSTypography.titleLarge)
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Real-time background state transitions.")
                            .font(DSTypography.caption)
                            .foregroundColor(DSColor.textSecondary)
                        
                        ForEach(store.deliveries.filter { $0.state != .created }) { delivery in
                            HStack {
                                Circle()
                                    .fill(Color(hex: delivery.state.progressColorHex))
                                    .frame(width: 8, height: 8)
                                VStack(alignment: .leading) {
                                    Text(delivery.id)
                                        .font(DSTypography.mono)
                                    Text("\(delivery.state.rawValue) - \(delivery.state.uiDescription)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if delivery.state == .committed {
                                    Image(systemName: "icloud.and.arrow.up.fill")
                                        .foregroundColor(DSColor.success)
                                } else if delivery.state == .uploading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "clock")
                                        .foregroundColor(DSColor.textSecondary)
                                }
                            }
                            .padding()
                            .background(DSColor.cardBackground)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// Dispute Replay Preview
struct DisputeReplayPreviewView: View {
    @State private var showDispute = false
    
    var body: some View {
        ZStack {
            DSColor.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 50))
                    .foregroundColor(DSColor.textSecondary)
                Text("Dispute Resolution")
                    .font(DSTypography.titleMedium)
                Text("Select a COMPLETELY committed delivery to replay the proof.")
                    .font(DSTypography.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(DSColor.textSecondary)
                
                PrimaryButton("View Demo Dispute") {
                    showDispute = true
                }
                .padding()
            }
        }
        .sheet(isPresented: $showDispute) {
            DisputeReplayView()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: AppStore())
    }
}
