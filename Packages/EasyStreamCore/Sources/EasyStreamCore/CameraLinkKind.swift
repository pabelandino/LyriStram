import Foundation

/// How a director source reaches the studio. Wi-Fi phones stay on WebRTC. ATEM inputs stay on the switcher.
public enum CameraLinkKind: String, Sendable, Equatable, Codable {
    case wifi
    case atem
}
