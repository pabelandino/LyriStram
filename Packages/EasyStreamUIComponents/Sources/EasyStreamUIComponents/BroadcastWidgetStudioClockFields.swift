import SwiftUI
import EasyStreamCore

struct BroadcastWidgetStudioClockFields: View {
    @Binding var configuration: BroadcastWidgetConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Mostrar segundos", isOn: $configuration.clockShowsSeconds)
            Toggle("Mostrar fecha", isOn: $configuration.clockShowsDate)
            Toggle("Formato 24 h", isOn: $configuration.clockUse24Hour)
            Toggle("Mostrar fondo", isOn: Binding(
                get: { configuration.resolvedClockShowsBackground },
                set: { configuration.clockShowsBackground = $0 }
            ))
            BroadcastWidgetStudioFontControls(
                configuration: $configuration,
                titleLabel: "Fuente de la hora",
                includeSubtitle: configuration.clockShowsDate,
                sizeLabel: "Tamaño de la hora"
            )
            BroadcastWidgetStudioPlacementSizeControls(configuration: $configuration)
        }
    }
}
