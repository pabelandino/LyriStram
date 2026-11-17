import LvoqStreamCore
import Foundation
import Observation

/// Persists the in-app language. `nil` follows the system language.
@MainActor
@Observable
final class AppLanguageStore {
    static let shared = AppLanguageStore()

    private let storageKey = "com.lvoqstream.uiLanguageCode"

    /// Bumps when the language changes so visible text is built again.
    private(set) var revision = 0

    var languageCode: String? {
        didSet {
            guard languageCode != oldValue else { return }
            revision &+= 1
            persist()
        }
    }

    private init() {
        AppLanguageBundle.install()
        let stored = UserDefaults.standard.string(forKey: storageKey)
        languageCode = AppLocale(rawValue: stored ?? "")?.languageCode
        // `didSet` does not run during init.
        persist()
    }

    private func persist() {
        AppLocalization.apply(preferredLanguageCode: languageCode)
        AppLanguageBundle.apply(languageCode: languageCode)
        if let languageCode {
            UserDefaults.standard.set(languageCode, forKey: storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
    }
}
