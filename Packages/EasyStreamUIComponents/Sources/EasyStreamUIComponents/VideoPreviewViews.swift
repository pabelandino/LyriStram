import SwiftUI
import WebRTC

#if canImport(UIKit)
import UIKit
import EasyStreamCameraCapture

/// WebRTC Metal views report full video resolution as intrinsic size, which breaks SwiftUI HStack layouts.
public final class LayoutNeutralRTCMTLVideoView: RTCMTLVideoView {
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    public override func invalidateIntrinsicContentSize() {}
}

public struct WebRTCVideoView: UIViewRepresentable {
    let track: RTCVideoTrack?

    public init(track: RTCVideoTrack?) {
        self.track = track
    }

    public func makeUIView(context: Context) -> ClippingRTCVideoContainerView {
        let container = ClippingRTCVideoContainerView()
        container.metalView.videoContentMode = .scaleAspectFit
        container.metalView.delegate = context.coordinator
        context.coordinator.render(track: track, in: container.metalView)
        return container
    }

    public func updateUIView(_ uiView: ClippingRTCVideoContainerView, context: Context) {
        context.coordinator.render(track: track, in: uiView.metalView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: ClippingRTCVideoContainerView, context: Context) -> CGSize? {
        boundedSize(for: proposal)
    }

    public final class Coordinator: NSObject, RTCVideoViewDelegate {
        private weak var currentTrack: RTCVideoTrack?

        func render(track: RTCVideoTrack?, in view: RTCMTLVideoView) {
            if currentTrack === track { return }
            currentTrack?.remove(view)
            currentTrack = track
            track?.add(view)
        }

        public func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {}
    }
}

public final class ClippingRTCVideoContainerView: UIView {
    let metalView = LayoutNeutralRTCMTLVideoView(frame: .zero)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        metalView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(metalView)
        NSLayoutConstraint.activate([
            metalView.leadingAnchor.constraint(equalTo: leadingAnchor),
            metalView.trailingAnchor.constraint(equalTo: trailingAnchor),
            metalView.topAnchor.constraint(equalTo: topAnchor),
            metalView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
}

public struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    public init(session: AVCaptureSession) {
        self.session = session
    }

    public func makeUIView(context: Context) -> PreviewContainerView {
        let view = PreviewContainerView()
        view.configure(session: session)
        return view
    }

    public func updateUIView(_ uiView: PreviewContainerView, context: Context) {
        uiView.configure(session: session)
    }
}

public final class PreviewContainerView: UIView {
    private let previewLayer = AVCaptureVideoPreviewLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        previewLayer.connection?.applyCurrentVideoOrientationIfSupported()
    }

    func configure(session: AVCaptureSession) {
        previewLayer.session = session
        previewLayer.connection?.applyCurrentVideoOrientationIfSupported()
    }
}

private func boundedSize(for proposal: ProposedViewSize) -> CGSize? {
    guard let width = proposal.width, let height = proposal.height else {
        return nil
    }
    return CGSize(width: width, height: height)
}

#elseif canImport(AppKit)
import AppKit
import AVFoundation

/// WebRTC Metal views report full video resolution as intrinsic size, which breaks SwiftUI HStack layouts.
public final class LayoutNeutralRTCMTLNSVideoView: RTCMTLNSVideoView {
    public override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }

    public override func invalidateIntrinsicContentSize() {}

    public override var fittingSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }
}

/// Keeps Metal WebRTC views clipped to SwiftUI layout bounds on macOS.
public final class ClippingRTCVideoContainer: NSView {
    public let metalView: LayoutNeutralRTCMTLNSVideoView

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
        metalView.translatesAutoresizingMaskIntoConstraints = true
        metalView.autoresizingMask = [.width, .height]
        addSubview(metalView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }

    public override var fittingSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }

    public override func layout() {
        super.layout()
        metalView.frame = bounds
    }
}

public struct WebRTCVideoView: NSViewRepresentable {
    let track: RTCVideoTrack?

    public init(track: RTCVideoTrack?) {
        self.track = track
    }

    public func makeNSView(context: Context) -> ClippingRTCVideoContainer {
        let container = ClippingRTCVideoContainer()
        context.coordinator.render(track: track, in: container.metalView)
        return container
    }

    public func updateNSView(_ nsView: ClippingRTCVideoContainer, context: Context) {
        context.coordinator.render(track: track, in: nsView.metalView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, nsView: ClippingRTCVideoContainer, context: Context) -> CGSize? {
        boundedSize(for: proposal)
    }

    public final class Coordinator {
        private weak var currentTrack: RTCVideoTrack?

        func render(track: RTCVideoTrack?, in view: RTCMTLNSVideoView) {
            if currentTrack === track { return }
            currentTrack?.remove(view)
            currentTrack = track
            track?.add(view)
        }
    }
}

public struct CameraPreviewView: NSViewRepresentable {
    let session: AVCaptureSession

    public init(session: AVCaptureSession) {
        self.session = session
    }

    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer = CALayer()
        view.wantsLayer = true
        view.layer?.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.previewLayer?.session = session
        context.coordinator.previewLayer?.frame = nsView.bounds
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public final class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

private func boundedSize(for proposal: ProposedViewSize) -> CGSize? {
    guard let width = proposal.width, let height = proposal.height else {
        return nil
    }
    return CGSize(width: width, height: height)
}
#endif
