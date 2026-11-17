import LvoqStreamCore
import LvoqStreamUIComponents
import SwiftUI

struct DirectorSettingsLanguageSection: View {
    @Bindable private var language = AppLanguageStore.shared

    var body: some View {
        DirectorInspectorSection(L10n.Settings.languageSection, systemImage: "globe") {
            Picker(L10n.Settings.languageSection, selection: selection) {
                Text(L10n.Settings.languageSystem).tag(LanguageChoice.system)
                ForEach(AppLocale.allCases) { locale in
                    Text(L10n.Settings.languageName(for: locale)).tag(LanguageChoice.locale(locale))
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            Text(L10n.Settings.languageFooter)
                .font(.footnote)
                .foregroundStyle(BroadcastTheme.subtleText)
        }
    }

    private var selection: Binding<LanguageChoice> {
        Binding(
            get: {
                guard let code = language.languageCode, let locale = AppLocale(rawValue: code) else {
                    return .system
                }
                return .locale(locale)
            },
            set: { choice in
                switch choice {
                case .system:
                    language.languageCode = nil
                case .locale(let locale):
                    language.languageCode = locale.languageCode
                }
            }
        )
    }
}

private enum LanguageChoice: Hashable {
    case system
    case locale(AppLocale)
}
