import SwiftUI
import WebRTC
import EasyStreamCore

/// One persistent Metal renderer per UI slot — swaps tracks without recreating the NSView/UIView.
public struct StableWebRTCVideoSurface: View {
    let track: RTCVideoTrack?
    let sinkCategory: VideoRendererSinkCategory
    let contentMode: WebRTCVideoContentMode

    public init(
        track: RTCVideoTrack?,
        sinkCategory: VideoRendererSinkCategory = .tile,
        contentMode: WebRTCVideoContentMode = .aspectFill
    ) {
        self.track = track
        self.sinkCategory = sinkCategory
        self.contentMode = contentMode
    }

    public var body: some View {
        WebRTCVideoView(track: track, sinkCategory: sinkCategory, contentMode: contentMode)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .clipped()
            .animation(nil, value: track.map { ObjectIdentifier($0) })
    }
}

/// Tile wrapper — identity is the camera slot, not the track object.
public struct DirectorCameraTileVideoSurface: View {
    let track: RTCVideoTrack?

    public init(track: RTCVideoTrack?) {
        self.track = track
    }

    public var body: some View {
        StableWebRTCVideoSurface(track: track, sinkCategory: .tile, contentMode: .aspectFill)
    }
}

/// Program bus wrapper — fills the 16:9 frame with no letterbox jump on source change.
public struct DirectorProgramVideoSurface: View {
    let track: RTCVideoTrack?

    public init(track: RTCVideoTrack?) {
        self.track = track
    }

    public var body: some View {
        StableWebRTCVideoSurface(track: track, sinkCategory: .program, contentMode: .aspectFill)
    }
}
