import Foundation

/// UI languages shipped with the app. Add a case here, the matching catalog
/// entries, and the code in the Xcode project's `knownRegions`.
public enum AppLocale: String, CaseIterable, Sendable, Identifiable {
    case english = "en"
    case spanish = "es"
    case portuguese = "pt"

    public var id: String { rawValue }

    public var languageCode: String { rawValue }

    public var settingsNameKey: String {
        switch self {
        case .english: "settings.language.name.en"
        case .spanish: "settings.language.name.es"
        case .portuguese: "settings.language.name.pt"
        }
    }
}

public enum AppLocaleCatalog {
    public static let supportedLanguageCodes: [String] = AppLocale.allCases.map(\.languageCode)
}
