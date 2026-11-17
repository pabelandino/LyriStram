#if canImport(UIKit)
import UIKit
import WebRTC

/// WebRTC Metal views report full video resolution as intrinsic size, which breaks SwiftUI HStack layouts.
public final class LayoutNeutralRTCMTLVideoView: RTCMTLVideoView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        isOpaque = true
        clipsToBounds = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    public override func invalidateIntrinsicContentSize() {}
}
#endif
