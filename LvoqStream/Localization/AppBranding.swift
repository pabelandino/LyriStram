import LvoqStreamCore
import Foundation

enum AppBranding {
    static let bundleIdentifier = "com.lvoqstream.app"

    /// User-visible app name. Follows the system language, or the in-app override.
    static var displayName: String { L10n.App.displayName }
}
