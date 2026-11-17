import Foundation

/// Director-side link to the LvoqShow air service.
public enum LvoqShowAirLink: String, Equatable, Sendable {
    case idle
    case searching
    case connected
}
