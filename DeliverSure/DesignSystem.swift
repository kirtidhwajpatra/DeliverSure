import SwiftUI

// MARK: - Design System: Colors
struct DSColor {
    // Primary - Trustworthy Blue (Calm, authoritative)
    static let primary = Color(hex: "0052CC") // Deep enterprise blue
    static let primaryBackground = Color(hex: "E6F0FF")
    
    // Status - Success (Not jarring neon, but earthy/reliable)
    static let success = Color(hex: "107C41")
    static let successBackground = Color(hex: "DFF6DD")
    
    // Status - Offline/Pending (Warm amber)
    static let warning = Color(hex: "B74700")
    static let warningBackground = Color(hex: "FFF4CE")
    
    // Neutrals
    static let background = Color(hex: "F7F9FC") // Very subtle cool gray for app background
    static let cardBackground = Color.white
    static let textPrimary = Color(hex: "172B4D") // High contrast, dark blue-gray
    static let textSecondary = Color(hex: "5E6C84")
    static let border = Color(hex: "DFE1E6")
    
    // Overlays
    static let overlayBackground = Color.black.opacity(0.8)
}

// MARK: - Design System: Typography
struct DSTypography {
    static let titleLarge = Font.system(size: 28, weight: .bold, design: .default)
    static let titleMedium = Font.system(size: 20, weight: .semibold, design: .default)
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let caption = Font.system(size: 13, weight: .medium, design: .default)
    static let mono = Font.system(size: 13, weight: .medium, design: .monospaced)
}

// MARK: - Design System: Components
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isEnabled: Bool = true
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 19, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56) // Large tap target
            .background(DSColor.primary)
            .cornerRadius(12)
            .shadow(color: DSColor.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(DSColor.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.clear)
        }
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    let backgroundColor: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
            Text(text.uppercased())
                .font(.system(size: 12, weight: .bold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundColor(color)
        .background(backgroundColor)
        .cornerRadius(100)
    }
}

// MARK: - Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
