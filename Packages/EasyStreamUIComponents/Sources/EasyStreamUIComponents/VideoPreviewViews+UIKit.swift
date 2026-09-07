#if canImport(UIKit)
import SwiftUI
import WebRTC
import EasyStreamCore
import UIKit

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
            if currentTrack === track, currentView === view {
                return
            }

            if let track, let current = currentTrack, currentView === view {
                if current.trackId == track.trackId {
                    if current !== track {
                        current.remove(view)
                        track.add(view)
                        currentTrack = track
                    }
                    return
                }
                current.remove(view)
                track.add(view)
                if let registeredCategory {
                    VideoRendererSinkRegistry.unregister(registeredCategory)
                }
                VideoRendererSinkRegistry.register(category)
                registeredCategory = category
                currentTrack = track
                return
            }

            detachCurrent()
            currentTrack = track
            currentView = view
            guard let track else { return }
            track.add(view)
            VideoRendererSinkRegistry.register(category)
            registeredCategory = category
        }

        private func detachCurrent() {
            if let previousTrack = currentTrack, let previousView = currentView {
                previousTrack.remove(previousView)
            }
            if let registeredCategory {
                VideoRendererSinkRegistry.unregister(registeredCategory)
                self.registeredCategory = nil
            }
            currentTrack = nil
            currentView = nil
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
            detachCurrent()
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

        public func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
            guard let trackId = currentTrack?.trackId else { return }
            Task { @MainActor in
                LiveVideoStreamSizeStore.shared.update(trackId: trackId, size: size)
            }
        }
    }
}
#endif
