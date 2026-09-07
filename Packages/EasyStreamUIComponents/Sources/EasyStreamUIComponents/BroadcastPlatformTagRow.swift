import SwiftUI
import EasyStreamCore

struct BroadcastPlatformTagRow: View {
    let platforms: [BroadcastPlatform]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(platforms, id: \.self) { platform in
                Text(platform.shortLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(platform.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(platform.accentColor.opacity(0.14), in: Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(platform.accentColor.opacity(0.28), lineWidth: 0.5)
                    }
            }
        }
    }
}

extension BroadcastPlatform {
    var accentColor: Color {
        switch self {
        case .youtube: Color(red: 0.95, green: 0.22, blue: 0.18)
        case .facebook: Color(red: 0.28, green: 0.52, blue: 0.96)
        case .rtmp: BroadcastTheme.copper
        }
    }
}
