import SwiftUI
import WebRTC
import EasyStreamCore

/// Wraps WebRTC video so layout stays within the parent's proposed bounds (16:9).
public struct BoundedWebRTCVideoView: View {
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
        StableWebRTCVideoSurface(
            track: track,
            sinkCategory: sinkCategory,
            contentMode: contentMode
        )
    }
}
