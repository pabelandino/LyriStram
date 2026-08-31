import Foundation

/// Delivery modes aligned with Apple media stack capabilities.
///
/// - LAN camera transport uses WebRTC for ultra-low latency (not HLS).
/// - Program output to social platforms uses RTMPS ingest.
/// - HLS ([Apple HTTP Live Streaming](https://developer.apple.com/documentation/http-live-streaming))
///   remains available for future monitoring, VOD, or LL-HLS distribution paths
///   where segment-based delivery is acceptable.
public enum StreamingDeliveryMode: String, Sendable, CaseIterable {
    case webrtcLAN
    case rtmps
    case hls

    public var displayName: String {
        switch self {
        case .webrtcLAN: "WebRTC (LAN)"
        case .rtmps: "RTMPS"
        case .hls: "HLS"
        }
    }
}
