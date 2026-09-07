import SwiftUI
import EasyStreamCore

struct BroadcastWidgetStudioTickerFields: View {
    @Binding var configuration: BroadcastWidgetConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Texto del ticker", text: $configuration.tickerText, prompt: Text("Escribe el texto con espacios"))
                .textFieldStyle(.roundedBorder)
#if os(macOS)
                .disableAutocorrection(true)
#endif

            HStack {
                Text("Color del texto")
                    .font(.caption)
                Spacer()
                BroadcastHexColorWell(
                    optionalHex: $configuration.tickerTextColorHex,
                    supportsOpacity: false,
                    fallback: "FFFFFF"
                )
            }

            Toggle(
                "Fondo con gradiente",
                isOn: BroadcastWidgetStudioGradientBindings.useTickerGradient($configuration)
            )

            if configuration.resolvedUseTickerGradient {
                BroadcastWidgetStudioSharedControls.gradientColorRow(
                    "Inicio",
                    hex: BroadcastWidgetStudioGradientBindings.tickerGradientStart($configuration)
                )
                BroadcastWidgetStudioSharedControls.gradientColorRow(
                    "Fin",
                    hex: BroadcastWidgetStudioGradientBindings.tickerGradientEnd($configuration)
                )
            } else {
                HStack {
                    Text("Color de fondo")
                        .font(.caption)
                    Spacer()
                    BroadcastHexColorWell(
                        optionalHex: $configuration.tickerBackgroundHex,
                        supportsOpacity: true,
                        fallback: "CC000000"
                    )
                }
            }

            BroadcastWidgetStudioTickerPlacementControls(configuration: $configuration)

            Stepper(
                "Velocidad: \(Int(configuration.tickerSpeed)) pt/s",
                value: $configuration.tickerSpeed,
                in: 30...200,
                step: 5
            )
            BroadcastWidgetStudioFontControls(
                configuration: $configuration,
                titleLabel: "Fuente del ticker",
                includeSubtitle: false
            )
        }
    }
}
