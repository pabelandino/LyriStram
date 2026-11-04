import SwiftUI
import EasyStreamCore

/// Places a live graphic once. GeometryReader was remeasured while the logo
/// turned and that layout pass stalled scroll and toggles in the same window.
struct WidgetLivePlacementLayout: Layout {
    var placement: BroadcastWidgetPlacement
    var sizing: WidgetOverlayContentSizing

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let subview = subviews.first else { return }
        let rect = WidgetPlacementGeometry.rect(from: placement, canvas: bounds.size, sizing: sizing)
        subview.place(
            at: CGPoint(x: bounds.minX + rect.minX, y: bounds.minY + rect.minY),
            anchor: .topLeading,
            proposal: ProposedViewSize(width: rect.width, height: rect.height)
        )
    }
}
