import Foundation

/// Same Bonjour service Lvoq Show uses. The JSON kinds and loopback port are unchanged.
public enum LvoqShowAir {
    public static let bonjourType = "_lvoqshow-sync._tcp"
    public static let bonjourDomain = "local."
    public static let serviceName = "Lvoq Show"
    /// Same-Mac path. Bonjour can deny a newly added service type; loopback does not ask mDNS.
    public static let loopbackPort: UInt16 = 47621
}
