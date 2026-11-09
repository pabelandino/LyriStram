import Foundation

/// Director-side link to the Lyriora air service.
public enum LyrioraAirLink: String, Equatable, Sendable {
    case idle
    case searching
    case connected
}
