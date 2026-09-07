import SwiftUI
import EasyStreamCore

struct BroadcastWidgetStudioLowerThirdFields: View {
    @Binding var configuration: BroadcastWidgetConfiguration
    let onImportLogo: () -> Void
    let onImportLogoFromPhotoLibrary: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Título", text: $configuration.title)
                .textFieldStyle(.roundedBorder)
            TextField("Subtítulo", text: Binding(
                get: { configuration.subtitle ?? "" },
                set: { configuration.subtitle = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)

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
                    "Color fondo",
                    optionalHex: $configuration.accentColorHex,
                    fallback: "007AFF"
                )
            }

            BroadcastWidgetStudioOptionalLogoImportControl(
                onImportLogo: onImportLogo,
                onImportLogoFromPhotoLibrary: onImportLogoFromPhotoLibrary
            )

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
}
