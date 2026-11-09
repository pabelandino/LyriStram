import SwiftUI
import EasyStreamCore

/// Wi-Fi phones show a radio mark plus the Apple or Android logo. ATEM inputs show the switcher name.
struct MonitorSourceLinkBadge: View {
    let link: CameraLinkKind
    let platform: DevicePlatform

    var body: some View {
        HStack(spacing: 4) {
            switch link {
            case .wifi:
                Image(systemName: "wifi")
                    .font(.caption2.weight(.bold))
                CameraPlatformBrandIcon(platform: platform, size: 12)
            case .atem:
                Text("ATEM")
                    .font(.caption2.weight(.heavy))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 4))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        switch link {
        case .wifi:
            "Wi-Fi \(platform.displayName)"
        case .atem:
            "ATEM"
        }
    }
}
