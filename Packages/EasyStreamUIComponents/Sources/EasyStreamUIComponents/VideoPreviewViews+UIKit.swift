#if canImport(UIKit)
import SwiftUI
import WebRTC
import EasyStreamCore
import UIKit
import EasyStreamCameraCapture

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

public struct WebRTCVideoView: UIViewRepresentable, Equatable {
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

    public func makeUIView(context: Context) -> ClippingRTCVideoContainerView {
        let container = ClippingRTCVideoContainerView()
        container.metalView.videoContentMode = contentMode.uiMetalMode
        container.metalView.delegate = context.coordinator
        context.coordinator.attach(track: track, category: sinkCategory, to: container.metalView)
        context.coordinator.startOrientationRefresh { [weak coordinator = context.coordinator] in
            coordinator?.refreshRenderer()
        }
        return container
    }

    public func updateUIView(_ uiView: ClippingRTCVideoContainerView, context: Context) {
        uiView.metalView.videoContentMode = contentMode.uiMetalMode
        context.coordinator.attach(track: track, category: sinkCategory, to: uiView.metalView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: ClippingRTCVideoContainerView, context: Context) -> CGSize? {
        VideoPreviewLayout.boundedSize(for: proposal)
    }

    public final class Coordinator: NSObject, RTCVideoViewDelegate {
        private weak var currentTrack: RTCVideoTrack?
        private weak var currentView: RTCMTLVideoView?
        private var registeredCategory: VideoRendererSinkCategory?
        private var orientationObserver: NSObjectProtocol?
        private var sceneActivationObserver: NSObjectProtocol?
        private var appActiveObserver: NSObjectProtocol?
        private var refreshWorkItem: DispatchWorkItem?

        func attach(
            track: RTCVideoTrack?,
            category: VideoRendererSinkCategory,
            to view: RTCMTLVideoView
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

        func refreshRenderer() {
            refreshWorkItem?.cancel()
            let work = DispatchWorkItem { [weak self] in
                guard let view = self?.currentView else { return }
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
            refreshWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: work)
        }

        func startOrientationRefresh(onRefresh: @escaping () -> Void) {
            guard orientationObserver == nil else { return }

            orientationObserver = NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in onRefresh() }

            sceneActivationObserver = NotificationCenter.default.addObserver(
                forName: UIScene.didActivateNotification,
                object: nil,
                queue: .main
            ) { _ in onRefresh() }

            appActiveObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { _ in onRefresh() }
        }

        deinit {
            refreshWorkItem?.cancel()
            if let registeredCategory {
                VideoRendererSinkRegistry.unregister(registeredCategory)
            }
            if let orientationObserver {
                NotificationCenter.default.removeObserver(orientationObserver)
            }
            if let sceneActivationObserver {
                NotificationCenter.default.removeObserver(sceneActivationObserver)
            }
            if let appActiveObserver {
                NotificationCenter.default.removeObserver(appActiveObserver)
            }
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

    public override func layoutSubviews() {
        super.layoutSubviews()
        metalView.setNeedsLayout()
        metalView.layoutIfNeeded()
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

private extension WebRTCVideoContentMode {
    var uiMetalMode: UIView.ContentMode {
        switch self {
        case .aspectFit: .scaleAspectFit
        case .aspectFill: .scaleAspectFill
        }
    }
}
#endif
