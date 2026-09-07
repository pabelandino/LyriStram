#if canImport(AppKit)
import AppKit
import WebRTC

/// Keeps Metal WebRTC views clipped to SwiftUI layout bounds on macOS.
public final class ClippingRTCVideoContainer: NSView {
    public let metalView: LayoutNeutralRTCMTLNSVideoView
    var contentMode: WebRTCVideoContentMode = .aspectFill {
        didSet {
            guard oldValue != contentMode else { return }
            needsLayout = true
        }
    }

    private var videoSize: CGSize = .zero

    public override init(frame frameRect: NSRect) {
        metalView = LayoutNeutralRTCMTLNSVideoView(frame: .zero)
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = true
        clipsToBounds = true
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        metalView.wantsLayer = true
        metalView.layer?.masksToBounds = true
        addSubview(metalView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateVideoSize(_ size: CGSize) {
        guard contentMode != .aspectFill else { return }
        guard size.width > 1, size.height > 1 else { return }
        guard size != videoSize else { return }
        videoSize = size
        needsLayout = true
    }

    func resetVideoSizeForTrackSwap() {
        guard contentMode != .aspectFill else { return }
        videoSize = .zero
        needsLayout = true
    }

    public override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }

    public override var fittingSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }

    public override func invalidateIntrinsicContentSize() {}

    public override func layout() {
        super.layout()
        let displayRect = WebRTCVideoScaling.displayRect(
            videoSize: videoSize,
            containerSize: bounds.size,
            mode: contentMode
        )
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0
            context.allowsImplicitAnimation = false
            metalView.frame = displayRect
        }
    }
}
#endif
