import SwiftUI

/// SwiftUI layout that always reports an exact size — ignores child intrinsic content (e.g. WebRTC 1920×1080).
public struct BroadcastFixedSizeLayout: Layout {
    public let size: CGSize

    public init(width: CGFloat, height: CGFloat) {
        size = CGSize(width: width, height: height)
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        size
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let subview = subviews.first else { return }
        subview.place(
            at: CGPoint(x: bounds.minX, y: bounds.minY),
            anchor: .topLeading,
            proposal: ProposedViewSize(size)
        )
    }
}
