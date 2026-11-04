import SwiftUI
import EasyStreamCore

struct BroadcastWidgetStudioLowerThirdFields: View {
    @Binding var configuration: BroadcastWidgetConfiguration
    let onImportLogo: () -> Void
    let onImportLogoFromPhotoLibrary: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Variante", selection: Binding(
                get: { configuration.resolvedLowerThirdStyle },
                set: { style in
                    configuration.lowerThirdStyle = style
                    configuration.applyLowerThirdStyleColors()
                }
            )) {
                ForEach(BroadcastLowerThirdStyle.allCases, id: \.self) { style in
                    Text(style.displayName).tag(style)
                }
            }
            Text("Al aire entra, espera y sale solo. Vuelve a verse solo si lo agregas otra vez.")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(titlePrompt, text: $configuration.title)
                .textFieldStyle(.roundedBorder)
            TextField(subtitlePrompt, text: Binding(
                get: { configuration.subtitle ?? "" },
                set: { configuration.subtitle = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)
            if configuration.resolvedLowerThirdStyle == .angular {
                TextField("Línea inferior", text: $configuration.tickerText)
                    .textFieldStyle(.roundedBorder)
            }

            BroadcastWidgetStudioSharedControls.colorWellRow(
                "Color título",
                optionalHex: $configuration.titleColorHex,
                fallback: "FFFFFF"
            )
            BroadcastWidgetStudioSharedControls.colorWellRow(
                "Color subtítulo",
                optionalHex: $configuration.subtitleColorHex,
                fallback: "FFFFFFE6"
            )

            Toggle(
                "Fondo con gradiente",
                isOn: BroadcastWidgetStudioGradientBindings.useLowerThirdGradient($configuration)
            )

            if configuration.resolvedUseLowerThirdGradient {
                BroadcastWidgetStudioSharedControls.gradientColorRow(
                    "Gradiente inicio",
                    hex: BroadcastWidgetStudioGradientBindings.lowerThirdGradientStart($configuration)
                )
                BroadcastWidgetStudioSharedControls.gradientColorRow(
                    "Gradiente fin",
                    hex: BroadcastWidgetStudioGradientBindings.lowerThirdGradientEnd($configuration)
                )
            } else {
                BroadcastWidgetStudioSharedControls.colorWellRow(
                    accentPrompt,
                    optionalHex: $configuration.accentColorHex,
                    fallback: "E6A817"
                )
            }

            if configuration.resolvedLowerThirdStyle != .guestPlain {
                BroadcastWidgetStudioOptionalLogoImportControl(
                    onImportLogo: onImportLogo,
                    onImportLogoFromPhotoLibrary: onImportLogoFromPhotoLibrary
                )
            }

            Toggle("Secuencia automática", isOn: $configuration.autoPlaySequence)
            Stepper(
                "Visible: \(Int(configuration.holdDurationSeconds)) s",
                value: $configuration.holdDurationSeconds,
                in: 2...30
            )
            BroadcastWidgetStudioFontControls(
                configuration: $configuration,
                titleLabel: "Fuente título",
                includeSubtitle: true
            )
        }
    }

    private var titlePrompt: String {
        switch configuration.resolvedLowerThirdStyle {
        case .angular: "Título"
        case .titlePlate: "Título principal"
        case .guest, .guestPlain: "Nombre"
        }
    }

    private var subtitlePrompt: String {
        switch configuration.resolvedLowerThirdStyle {
        case .angular: "Subtítulo"
        case .titlePlate: "Texto del recuadro"
        case .guest, .guestPlain: "Presentación"
        }
    }

    private var accentPrompt: String {
        switch configuration.resolvedLowerThirdStyle {
        case .angular: "Color de acento"
        case .titlePlate: "Color del recuadro"
        case .guest, .guestPlain: "Color de la barra"
        }
    }
}
