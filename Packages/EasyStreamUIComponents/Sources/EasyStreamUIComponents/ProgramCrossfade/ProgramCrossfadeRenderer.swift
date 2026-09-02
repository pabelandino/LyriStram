import WebRTC

enum ProgramCrossfadeRenderer {
    static func swapAttach(
        _ track: RTCVideoTrack?,
        to view: RTCVideoRenderer,
        storage: inout RTCVideoTrack?
    ) {
        guard storage !== track else { return }
        if let track {
            track.add(view)
        }
        if let previous = storage, previous !== track {
            previous.remove(view)
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
