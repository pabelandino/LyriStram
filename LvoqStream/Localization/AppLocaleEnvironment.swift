import LvoqStreamCore
import SwiftUI

private struct AppLocaleEnvironmentModifier: ViewModifier {
    let languageCode: String?

    func body(content: Content) -> some View {
        let _ = languageCode
        content.environment(\.locale, AppLocalization.resolvedLocale)
    }
}

extension View {
    func appLocaleEnvironment(languageCode: String?) -> some View {
        modifier(AppLocaleEnvironmentModifier(languageCode: languageCode))
    }

    /// Applies the saved language, or the system language when no override is stored.
    func appLocaleEnvironment() -> some View {
        modifier(AppLanguageRootModifier())
    }
}

private struct AppLanguageRootModifier: ViewModifier {
    @Bindable private var language = AppLanguageStore.shared

    func body(content: Content) -> some View {
        let _ = language.revision
        content
            .appLocaleEnvironment(languageCode: language.languageCode)
            .environment(\.lvoqLanguageRefresh, language.revision)
    }
}

private struct LanguageRefreshKey: EnvironmentKey {
    static let defaultValue = 0
}

extension EnvironmentValues {
    /// Bumps when the in-app language changes so views re-resolve copy without tearing down session state.
    var lvoqLanguageRefresh: Int {
        get { self[LanguageRefreshKey.self] }
        set { self[LanguageRefreshKey.self] = newValue }
    }
}

extension View {
    /// Depends on the current language generation so `L10n` strings refresh in this subtree.
    func lvoqRefreshOnLanguageChange() -> some View {
        modifier(LanguageRefreshObserver())
    }
}

private struct LanguageRefreshObserver: ViewModifier {
    @Bindable private var language = AppLanguageStore.shared

    func body(content: Content) -> some View {
        let _ = language.revision
        content.environment(\.lvoqLanguageRefresh, language.revision)
    }
}
