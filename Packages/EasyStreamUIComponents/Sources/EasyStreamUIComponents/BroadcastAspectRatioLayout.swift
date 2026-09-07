import SwiftUI

/// Single-pass 16:9 layout — avoids GeometryReader reposition flicker on track swaps.
public struct BroadcastAspectRatioLayout: Layout {
    public let ratio: CGFloat

    public init(ratio: CGFloat = 16 / 9) {
        self.ratio = ratio
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let maxWidth = proposal.width, let maxHeight = proposal.height,
              maxWidth > 0, maxHeight > 0 else {
            return .zero
        }
        let containerRatio = maxWidth / maxHeight
        if containerRatio > ratio {
            let height = maxHeight
            return CGSize(width: height * ratio, height: height)
        }
        let width = maxWidth
        return CGSize(width: width, height: width / ratio)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let subview = subviews.first else { return }
        subview.place(at: CGPoint(x: bounds.minX, y: bounds.minY), anchor: .topLeading, proposal: ProposedViewSize(bounds.size))
    }
}
