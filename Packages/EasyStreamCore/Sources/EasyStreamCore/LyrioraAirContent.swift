import Foundation

/// What Lyriora is presenting. Wire values stay stable for the director.
public enum LyrioraAirContent: String, Codable, Equatable, Sendable {
    case lyric
    case bible
    case clear
}
