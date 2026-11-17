import Foundation
import os

/// In-app language override. When `preferredLanguageCode` is nil, the app follows the system.
public enum AppLocalization {
    private static let state = OSAllocatedUnfairLock<String?>(initialState: nil)

    public static var preferredLanguageCode: String? {
        state.withLock { $0 }
    }

    public static func apply(preferredLanguageCode code: String?) {
        let normalized = code.flatMap { AppLocale(rawValue: $0)?.languageCode }
        state.withLock { $0 = normalized }
    }

    /// Saved choice, or the system language when it is one we ship. Otherwise English.
    public static var resolvedLanguageCode: String {
        if let code = preferredLanguageCode {
            return code
        }
        for identifier in Locale.preferredLanguages {
            let code = Locale(identifier: identifier).language.languageCode?.identifier ?? identifier
            if let match = AppLocale(rawValue: code) {
                return match.languageCode
            }
        }
        return AppLocale.english.languageCode
    }

    public static var resolvedLocale: Locale {
        Locale(identifier: resolvedLanguageCode)
    }
}
