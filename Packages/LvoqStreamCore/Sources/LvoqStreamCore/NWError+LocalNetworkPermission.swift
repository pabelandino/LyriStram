import Foundation
import Network

public extension NWError {
    /// Bonjour / local-network permission denial (e.g. macOS `NoAuth`, `-65555`).
    var isLvoqStreamLocalNetworkPermissionIssue: Bool {
        switch self {
        case .dns(let code):
            return code == kDNSServiceErr_NoAuth
        case .posix(let code):
            return code == .EHOSTUNREACH || code == .EPERM
        default:
            return false
        }
    }
}

public enum LvoqStreamNetworkMessages {
    public static var localNetworkPermissionRequired: String {
        BundleLocalization.string("network.local.permission_required")
    }

    public static var localNetworkPermissionPromptHint: String {
        BundleLocalization.string("network.local.permission_hint")
    }
}
