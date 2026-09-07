import SwiftUI
import EasyStreamCore

/// Corner resize handle — circular dot only (no L-bars that read as crosses).
struct WidgetCornerHandle: View {
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [.white, Color.white.opacity(0.88)],
                    center: .center,
                    startRadius: 0,
                    endRadius: 8
                )
            )
            .frame(width: 14, height: 14)
            .overlay { Circle().strokeBorder(BroadcastTheme.studioAccent, lineWidth: 2) }
            .shadow(color: BroadcastTheme.studioAccent.opacity(0.5), radius: 4)
    }
}
