import Foundation

public struct CameraSourceID: Hashable, Sendable, Codable, Identifiable {
    public let rawValue: UUID
    public var id: UUID { rawValue }

    public init(_ rawValue: UUID) {
        self.rawValue = rawValue
    }
}
