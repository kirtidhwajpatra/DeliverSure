import SwiftUI

struct DisputeReplayView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Mock Data for the Replay
    let events = [
        (time: "10:42:15 AM", description: "Driver arrived at location (Geofence Enter)", icon: "location.fill"),
        (time: "10:43:00 AM", description: "Motion detected: Walking to door", icon: "figure.walk"),
        (time: "10:43:45 AM", description: "Device orientation changed: Portrait (Scan)", icon: "iphone"),
        (time: "10:43:48 AM", description: "Photo Captured (High Confidence)", icon: "camera.shutter.button.fill"),
        (time: "10:43:50 AM", description: "Delivery Marked Complete", icon: "checkmark.circle.fill")
    ]
    
    var body: some View {
        ZStack {
            DSColor.background.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DSColor.textPrimary)
                            .padding(12)
                            .background(DSColor.cardBackground)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    Spacer()
                    Text("Evidence Timeline")
                        .font(DSTypography.titleMedium)
                    Spacer()
                    Image(systemName: "xmark").hidden()
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Map Snapshot Placeholder
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                VStack {
                                    Image(systemName: "map.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("GPS Route Replay Overlay")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                            .cornerRadius(12)
                            .padding()
                        
                        // Timeline
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(0..<events.count, id: \.self) { index in
                                let event = events[index]
                                HStack(alignment: .top, spacing: 16) {
                                    // Timeline Line
                                    VStack(spacing: 0) {
                                        Circle()
                                            .fill(index == events.count - 1 ? DSColor.success : DSColor.primary)
                                            .frame(width: 12, height: 12)
                                        if index < events.count - 1 {
                                            Rectangle()
                                                .fill(DSColor.border)
                                                .frame(width: 2)
                                                .frame(minHeight: 40)
                                        }
                                    }
                                    .frame(width: 20)
                                    
                                    // Content
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(event.time)
                                            .font(DSTypography.mono)
                                            .foregroundColor(DSColor.textSecondary)
                                        Text(event.description)
                                            .font(DSTypography.bodyBold)
                                            .foregroundColor(DSColor.textPrimary)
                                    }
                                    .padding(.bottom, 24)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
    }
}

struct DisputeReplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisputeReplayView()
    }
}
