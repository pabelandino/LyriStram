import SwiftUI
import EasyStreamCore

struct BroadcastWidgetStudioTickerPlacementControls: View {
    @Binding var configuration: BroadcastWidgetConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tamaño y posición")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            Stepper(
                "Ancho: \(Int(configuration.placement.widthFraction * 100))%",
                value: $configuration.placement.widthFraction,
                in: 0.2...1,
                step: 0.01
            )

            Stepper(
                "Alto del fondo: \(Int(configuration.placement.heightFraction * 100))%",
                value: $configuration.placement.heightFraction,
                in: 0.04...0.4,
                step: 0.01
            )

            Text("Usa «Mover y redimensionar» para arrastrar el ticker en el preview.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
        }
    }
}
