import SwiftUI
import EasyStreamCore

struct BroadcastWidgetStudioFontControls: View {
    @Binding var configuration: BroadcastWidgetConfiguration
    let titleLabel: String
    let includeSubtitle: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tipografía")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Picker(titleLabel, selection: $configuration.titleFont) {
                ForEach(BroadcastFontPreset.allCases, id: \.self) { font in
                    Text(font.displayName).tag(font)
                }
            }
#if os(macOS)
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
#endif
            Stepper(
                "Tamaño: \(Int(configuration.titleFontSize)) pt",
                value: $configuration.titleFontSize,
                in: 12...120
            )
            if includeSubtitle {
                Picker("Fuente subtítulo", selection: $configuration.subtitleFont) {
                    ForEach(BroadcastFontPreset.allCases, id: \.self) { font in
                        Text(font.displayName).tag(font)
                    }
                }
#if os(macOS)
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
#endif
                Stepper(
                    "Tamaño subtítulo: \(Int(configuration.subtitleFontSize)) pt",
                    value: $configuration.subtitleFontSize,
                    in: 10...48
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
