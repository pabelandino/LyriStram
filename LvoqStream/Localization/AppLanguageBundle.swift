import Foundation
import LvoqStreamCore
import ObjectiveC
import os

/// Points `Bundle` lookups at the selected language without waiting for a relaunch.
enum AppLanguageBundle {
    private static let override = OSAllocatedUnfairLock<Bundle?>(initialState: nil)
    private static let installed = OSAllocatedUnfairLock(initialState: false)

    static func install() {
        let shouldInstall = installed.withLock { flag -> Bool in
            if flag { return false }
            flag = true
            return true
        }
        guard shouldInstall else { return }
        guard let original = class_getInstanceMethod(
            Bundle.self,
            #selector(Bundle.localizedString(forKey:value:table:))
        ),
        let swizzled = class_getInstanceMethod(
            Bundle.self,
            #selector(Bundle.lvoq_localizedString(forKey:value:table:))
        ) else { return }
        method_exchangeImplementations(original, swizzled)
    }

    /// `nil` follows the resolved system language. A code uses that `.lproj` for every lookup.
    static func apply(languageCode: String?) {
        let effective = languageCode ?? AppLocalization.resolvedLanguageCode
        let bundle: Bundle? = Bundle.main.path(forResource: effective, ofType: "lproj").flatMap(Bundle.init(path:))
        override.withLock { $0 = bundle }
    }

    fileprivate static var currentOverride: Bundle? {
        override.withLock { $0 }
    }
}

extension Bundle {
    @objc func lvoq_localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let override = AppLanguageBundle.currentOverride, override !== self {
            let missing = "\u{0}"
            // After the exchange, this call is the original lookup inside the chosen lproj.
            let translated = override.lvoq_localizedString(forKey: key, value: missing, table: tableName)
            if translated != missing {
                return translated
            }
            if tableName != "Localizable" {
                let fromCatalog = override.lvoq_localizedString(forKey: key, value: missing, table: "Localizable")
                if fromCatalog != missing {
                    return fromCatalog
                }
            }
        }
        return lvoq_localizedString(forKey: key, value: value, table: tableName)
    }
}
