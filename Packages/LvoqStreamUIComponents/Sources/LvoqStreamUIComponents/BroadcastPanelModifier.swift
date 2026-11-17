import SwiftUI

public struct BroadcastPanelModifier: ViewModifier {
    let elevated: Bool

    public init(elevated: Bool = false) {
        self.elevated = elevated
    }

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(elevated ? BroadcastTheme.panelElevated : BroadcastTheme.panelBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1)
            )
    }
}

public extension View {
    func broadcastPanel(elevated: Bool = false) -> some View {
        modifier(BroadcastPanelModifier(elevated: elevated))
    }
}
