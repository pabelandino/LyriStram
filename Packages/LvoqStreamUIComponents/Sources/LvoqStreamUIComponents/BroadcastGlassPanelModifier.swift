import SwiftUI

// MARK: - Panels

public struct BroadcastGlassPanelModifier: ViewModifier {
    let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = BroadcastGlassStyles.cardCornerRadius) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(BroadcastTheme.panelElevated)
            )
            .shadow(color: .black.opacity(0.28), radius: 10, y: 5)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(BroadcastTheme.glassHighlight, lineWidth: 0.75)
            }
    }
}

public extension View {
    func broadcastGlassPanel(cornerRadius: CGFloat = BroadcastGlassStyles.cardCornerRadius) -> some View {
        modifier(BroadcastGlassPanelModifier(cornerRadius: cornerRadius))
    }
}
