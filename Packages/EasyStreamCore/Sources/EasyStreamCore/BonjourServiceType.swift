import Foundation

/// Bonjour / mDNS service identifiers used for local device discovery.
public enum BonjourServiceType: String, Sendable, CaseIterable, Hashable {
    case camera = "_easystream-camera._tcp"
    case director = "_easystream-director._tcp"
    case intercom = "_easystream-intercom._udp"

    /// Value for `NSBonjourServices` in Info.plist.
    public var plistEntry: String { rawValue }

    /// Network.framework descriptor type (without leading underscore domain suffix handling).
    public var networkType: String { rawValue }

    /// TCP services used for WebRTC signaling (camera ↔ director).
    public var isSignalingService: Bool {
        self == .director || self == .camera
    }
}

public enum NetworkConstants {
    public static let protocolVersion = "1"
    public static let serviceDomain = "local."

    /// TXT record keys published in Bonjour advertisements.
    public enum TXTKey {
        public static let deviceID = "deviceID"
        public static let displayName = "displayName"
        public static let protocolVersion = "protocolVersion"
        public static let platform = "platform"
        public static let role = "role"
    }
}
