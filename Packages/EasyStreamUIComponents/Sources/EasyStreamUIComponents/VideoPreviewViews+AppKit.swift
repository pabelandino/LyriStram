#if canImport(AppKit)
import SwiftUI
import WebRTC
import EasyStreamCore
import AppKit

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
        container.contentMode = contentMode
        container.metalView.delegate = context.coordinator
        context.coordinator.bind(container: container)
        context.coordinator.attach(track: track, category: sinkCategory, to: container.metalView)
        return container
    }

    public func updateNSView(_ nsView: ClippingRTCVideoContainer, context: Context) {
        nsView.contentMode = contentMode
        nsView.metalView.delegate = context.coordinator
        context.coordinator.bind(container: nsView)
        context.coordinator.attach(track: track, category: sinkCategory, to: nsView.metalView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, nsView: ClippingRTCVideoContainer, context: Context) -> CGSize? {
        VideoPreviewLayout.boundedSize(for: proposal)
    }

    public final class Coordinator: NSObject, RTCVideoViewDelegate {
        private weak var currentTrack: RTCVideoTrack?
        private weak var currentView: RTCMTLNSVideoView?
        private weak var container: ClippingRTCVideoContainer?
        private var registeredCategory: VideoRendererSinkCategory?

        func bind(container: ClippingRTCVideoContainer) {
            self.container = container
        }

        func attach(
            track: RTCVideoTrack?,
            category: VideoRendererSinkCategory,
            to view: RTCMTLNSVideoView
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
            container?.resetVideoSizeForTrackSwap()
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

        public func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
            guard let trackId = currentTrack?.trackId else { return }
            container?.updateVideoSize(size)
            Task { @MainActor in
                LiveVideoStreamSizeStore.shared.update(trackId: trackId, size: size)
            }
        }

        deinit {
            detachCurrent()
        }
    }
}
#endif
