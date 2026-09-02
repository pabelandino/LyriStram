import SwiftUI
import WebRTC
import EasyStreamCore

/// Wraps WebRTC video so layout stays within the parent's proposed bounds (16:9).
public struct BoundedWebRTCVideoView: View {
    let track: RTCVideoTrack?
    let sinkCategory: VideoRendererSinkCategory

    public init(
        track: RTCVideoTrack?,
        sinkCategory: VideoRendererSinkCategory = .tile
    ) {
        self.track = track
        self.sinkCategory = sinkCategory
    }

    public var body: some View {
        GeometryReader { proxy in
            WebRTCVideoView(track: track, sinkCategory: sinkCategory)
                .equatable()
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .clipped()
    }
}
