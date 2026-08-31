import SwiftUI
import WebRTC

/// Wraps WebRTC video so layout stays within the parent's proposed bounds (16:9).
public struct BoundedWebRTCVideoView: View {
    let track: RTCVideoTrack?

    public init(track: RTCVideoTrack?) {
        self.track = track
    }

    public var body: some View {
        GeometryReader { proxy in
            WebRTCVideoView(track: track)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .clipped()
    }
}
