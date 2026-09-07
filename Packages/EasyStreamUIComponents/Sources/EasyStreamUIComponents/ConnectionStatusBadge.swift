import SwiftUI
import EasyStreamCore

public struct ConnectionStatusBadge: View {
    let isActive: Bool
    let label: String

    public init(isActive: Bool, label: String) {
        self.isActive = isActive
        self.label = label
    }

    public var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isActive ? BroadcastTheme.previewGreen : Color.orange)
                .frame(width: 8, height: 8)
                .shadow(color: isActive ? BroadcastTheme.previewGreen.opacity(0.5) : .clear, radius: 4)
            Text(label)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(BroadcastTheme.panelElevated, in: Capsule())
        .overlay(Capsule().strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1))
    }
}
