#if canImport(AppKit)
import SwiftUI
import WebRTC
import EasyStreamCore
import AppKit
import AVFoundation

/// WebRTC Metal views report full video resolution as intrinsic size, which breaks SwiftUI HStack layouts.
public final class LayoutNeutralRTCMTLNSVideoView: RTCMTLNSVideoView {
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

public struct WebRTCVideoView: NSViewRepresentable, Equatable {
    let track: RTCVideoTrack?
    let sinkCategory: VideoRendererSinkCategory
    let contentMode: WebRTCVideoContentMode

    public init(
        track: RTCVideoTrack?,
        sinkCategory: VideoRendererSinkCategory = .tile,
        contentMode: WebRTCVideoContentMode = .aspectFit
    ) {
        self.track = track
        self.sinkCategory = sinkCategory
        self.contentMode = contentMode
    }

    nonisolated public static func == (lhs: WebRTCVideoView, rhs: WebRTCVideoView) -> Bool {
        lhs.track === rhs.track
            && lhs.sinkCategory == rhs.sinkCategory
            && lhs.contentMode == rhs.contentMode
    }

    public func makeNSView(context: Context) -> ClippingRTCVideoContainer {
        let container = ClippingRTCVideoContainer()
        context.coordinator.attach(track: track, category: sinkCategory, to: container.metalView)
        return container
    }

    public func updateNSView(_ nsView: ClippingRTCVideoContainer, context: Context) {
        context.coordinator.attach(track: track, category: sinkCategory, to: nsView.metalView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, nsView: ClippingRTCVideoContainer, context: Context) -> CGSize? {
        VideoPreviewLayout.boundedSize(for: proposal)
    }

    public final class Coordinator {
        private weak var currentTrack: RTCVideoTrack?
        private weak var currentView: RTCMTLNSVideoView?
        private var registeredCategory: VideoRendererSinkCategory?

        func attach(
            track: RTCVideoTrack?,
            category: VideoRendererSinkCategory,
            to view: RTCMTLNSVideoView
        ) {
            guard currentTrack !== track || currentView !== view else { return }
            if let previousTrack = currentTrack, let previousView = currentView {
                previousTrack.remove(previousView)
                if let registeredCategory {
                    VideoRendererSinkRegistry.unregister(registeredCategory)
                    self.registeredCategory = nil
                }
            }
            currentTrack = track
            currentView = view
            if let track {
                track.add(view)
                VideoRendererSinkRegistry.register(category)
                registeredCategory = category
            }
        }

        deinit {
            if let registeredCategory {
                VideoRendererSinkRegistry.unregister(registeredCategory)
            }
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
#endif
