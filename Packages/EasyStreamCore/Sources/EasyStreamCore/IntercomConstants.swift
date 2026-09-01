import Foundation

public enum IntercomConstants {
    public static let port: UInt16 = 9856
    public static let sampleRate: Double = 16_000
    public static let senderIDByteCount = 16
}

public struct TeamIntercomPeer: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var displayName: String

    public init(id: UUID, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}
