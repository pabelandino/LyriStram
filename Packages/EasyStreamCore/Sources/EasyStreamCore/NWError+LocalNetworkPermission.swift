import Foundation
import Network

public extension NWError {
    /// Bonjour / local-network permission denial (e.g. macOS `NoAuth`, `-65555`).
    var isEasyStreamLocalNetworkPermissionIssue: Bool {
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

public enum EasyStreamNetworkMessages {
    public static let localNetworkPermissionRequired =
        "EasyStream necesita acceso a la red local para descubrir dispositivos y usar el intercom."

    public static let localNetworkPermissionPromptHint =
        "macOS mostrará un diálogo la primera vez. La app solo aparece en Ajustes después de ese diálogo. Cierra EasyStream por completo (⌘Q), ábrela de nuevo y elige Director o Cámara."
}
