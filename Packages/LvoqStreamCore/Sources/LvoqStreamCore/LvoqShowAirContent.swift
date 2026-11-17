import Foundation

/// What LvoqShow is presenting. Wire values stay stable for the director.
public enum LvoqShowAirContent: String, Codable, Equatable, Sendable {
    case lyric
    case bible
    case clear
}
