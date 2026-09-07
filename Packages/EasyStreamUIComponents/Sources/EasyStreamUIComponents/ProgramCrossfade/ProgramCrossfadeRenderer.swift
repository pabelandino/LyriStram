import WebRTC
import EasyStreamCore

enum ProgramCrossfadeRenderer {
    static func swapAttach(
        _ track: RTCVideoTrack?,
        to view: RTCVideoRenderer,
        storage: inout RTCVideoTrack?,
        sinkCategory: VideoRendererSinkCategory = .programCrossfade
    ) {
        if let track, let current = storage, current.trackId == track.trackId {
            if current !== track {
                ProgramBusTrace.event(
                    "renderer swapAttach rebind trackId=\(ProgramBusTrace.shortTrackId(track.trackId)) sink=\(sinkCategory)"
                )
                current.remove(view)
                track.add(view)
                storage = track
            }
            return
        }
        guard storage !== track else { return }
        if let previous = storage {
            previous.remove(view)
            VideoRendererSinkRegistry.unregister(sinkCategory)
        }
        if let track {
            track.add(view)
            VideoRendererSinkRegistry.register(sinkCategory)
        }
        storage = track
    }

    /// Rebinds even when the track reference is unchanged — RTCMTLVideoView often needs this after unhiding.
    static func forceAttach(
        _ track: RTCVideoTrack?,
        to view: RTCVideoRenderer,
        storage: inout RTCVideoTrack?
    ) {
        guard let track else {
            detachAndClear(view, storage: &storage)
            return
        }
        track.remove(view)
        track.add(view)
        storage = track
        refreshLayout(for: view)
    }

    static func detach(_ view: RTCVideoRenderer, storage: inout RTCVideoTrack?) {
        storage?.remove(view)
        storage = nil
    }

    /// Detaches the track and clears the last GPU frame so hidden slots cannot bleed through.
    static func detachAndClear(_ view: RTCVideoRenderer, storage: inout RTCVideoTrack?) {
        if storage != nil {
            VideoRendererSinkRegistry.unregister(.programCrossfade)
        }
        detach(view, storage: &storage)
        clearFrame(in: view)
    }

    static func clearFrame(in view: RTCVideoRenderer) {
#if canImport(UIKit)
        if let metalView = view as? RTCMTLVideoView {
            metalView.renderFrame(nil)
        }
#endif
#if canImport(AppKit)
        if let metalView = view as? RTCMTLNSVideoView {
            metalView.renderFrame(nil)
        }
#endif
    }

    private static func refreshLayout(for view: RTCVideoRenderer) {
#if canImport(UIKit)
        if let metalView = view as? RTCMTLVideoView {
            metalView.setNeedsLayout()
            metalView.layoutIfNeeded()
        }
#endif
#if canImport(AppKit)
        if let metalView = view as? RTCMTLNSVideoView {
            metalView.needsLayout = true
            metalView.layoutSubtreeIfNeeded()
        }
#endif
    }
}

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif
