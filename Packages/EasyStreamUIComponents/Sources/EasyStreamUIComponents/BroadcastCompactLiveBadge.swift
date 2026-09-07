import SwiftUI

/// Compact on-air indicator for narrow list rows.
public struct BroadcastCompactLiveBadge: View {
    public init() {}

    public var body: some View {
        Text("AIR")
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(BroadcastTheme.programRed)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(BroadcastTheme.programRed.opacity(0.16), in: Capsule())
            .overlay(Capsule().strokeBorder(BroadcastTheme.programRed.opacity(0.55), lineWidth: 0.75))
            .fixedSize()
            .accessibilityLabel("Al aire")
    }
}
