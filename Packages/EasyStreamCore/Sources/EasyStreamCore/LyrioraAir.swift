import Foundation

/// Same Bonjour service Lyriora already uses for SimplePlay.
public enum LyrioraAir {
    public static let bonjourType = "_lyriora-sync._tcp"
    public static let bonjourDomain = "local."
    public static let serviceName = "Lyriora"
    /// Same-Mac path. Bonjour can deny a newly added service type; loopback does not ask mDNS.
    public static let loopbackPort: UInt16 = 47621
}
