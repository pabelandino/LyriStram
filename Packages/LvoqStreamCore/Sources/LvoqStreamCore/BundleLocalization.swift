import Foundation

/// Resolves keys from the app target's `Localizable.xcstrings` using the active locale.
public enum BundleLocalization {
    public static let table = "Localizable"

    public static func string(_ key: String, table: String = table) -> String {
        String(
            localized: String.LocalizationValue(key),
            table: table,
            bundle: .main,
            locale: AppLocalization.resolvedLocale
        )
    }
}