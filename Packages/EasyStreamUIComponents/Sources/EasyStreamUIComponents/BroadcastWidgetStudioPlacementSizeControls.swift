import SwiftUI
import EasyStreamCore

struct BroadcastWidgetStudioPlacementSizeControls: View {
    @Binding var configuration: BroadcastWidgetConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tamaño en pantalla")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            Stepper(
                "Ancho: \(Int(configuration.placement.widthFraction * 100))%",
                value: $configuration.placement.widthFraction,
                in: 0.05...1,
                step: 0.01
            )

            Stepper(
                "Alto: \(Int(configuration.placement.heightFraction * 100))%",
                value: $configuration.placement.heightFraction,
                in: 0.05...1,
                step: 0.01
            )

            Text("También puedes arrastrar y redimensionar en el preview del programa.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
        }
    }
}
