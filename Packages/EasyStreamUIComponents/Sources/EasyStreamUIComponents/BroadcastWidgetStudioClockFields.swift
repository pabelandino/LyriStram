import SwiftUI
import EasyStreamCore

struct BroadcastWidgetStudioClockFields: View {
    @Binding var configuration: BroadcastWidgetConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Mostrar segundos", isOn: $configuration.clockShowsSeconds)
            Toggle("Mostrar fecha", isOn: $configuration.clockShowsDate)
            Toggle("Formato 24 h", isOn: $configuration.clockUse24Hour)
            BroadcastWidgetStudioFontControls(
                configuration: $configuration,
                titleLabel: "Fuente reloj",
                includeSubtitle: configuration.clockShowsDate
            )
        }
    }
}
