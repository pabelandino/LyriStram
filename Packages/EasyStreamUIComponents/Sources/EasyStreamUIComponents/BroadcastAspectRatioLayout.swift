import SwiftUI

/// Single-pass 16:9 layout — avoids GeometryReader reposition flicker on track swaps.
public struct BroadcastAspectRatioLayout: Layout {
    public let ratio: CGFloat

    public init(ratio: CGFloat = 16 / 9) {
        self.ratio = ratio
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width.flatMap { $0.isFinite && $0 > 0 ? $0 : nil }
        let maxHeight = proposal.height.flatMap { $0.isFinite && $0 > 0 ? $0 : nil }

        switch (maxWidth, maxHeight) {
        case let (width?, height?):
            let containerRatio = width / height
            if containerRatio > ratio {
                return CGSize(width: height * ratio, height: height)
            }
            return CGSize(width: width, height: width / ratio)
        case let (width?, nil):
            return CGSize(width: width, height: width / ratio)
        case let (nil, height?):
            return CGSize(width: height * ratio, height: height)
        case (nil, nil):
            return CGSize(width: 320, height: 320 / ratio)
        }
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let subview = subviews.first else { return }
        _ = proposal
        let fitted = fittedSize(in: bounds.size)
        let origin = CGPoint(
            x: bounds.midX - fitted.width / 2,
            y: bounds.midY - fitted.height / 2
        )
        subview.place(at: origin, anchor: .topLeading, proposal: ProposedViewSize(fitted))
    }

    private func fittedSize(in bounds: CGSize) -> CGSize {
        guard bounds.width > 0, bounds.height > 0 else {
            return CGSize(width: 320, height: 320 / ratio)
        }
        if bounds.width / bounds.height > ratio {
            return CGSize(width: bounds.height * ratio, height: bounds.height)
        }
        return CGSize(width: bounds.width, height: bounds.width / ratio)
    }
}
