import SwiftUI
import EasyStreamCore

struct BroadcastWidgetStudioCountdownFields: View {
    @Binding var configuration: BroadcastWidgetConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Color")
                    .font(.caption)
                TextField("Hex", text: Binding(
                    get: { configuration.accentColorHex ?? "007AFF" },
                    set: { configuration.accentColorHex = $0 }
                ))
                .textFieldStyle(.roundedBorder)
            }
            Stepper(
                "Segundos: \(configuration.countdownSeconds)",
                value: $configuration.countdownSeconds,
                in: 5...3600,
                step: 5
            )
            Picker("Animación", selection: $configuration.countdownAnimation) {
                ForEach(BroadcastCountdownAnimation.allCases, id: \.self) { style in
                    Text(style.displayName).tag(style)
                }
            }
#if os(macOS)
            .pickerStyle(.menu)
#endif
            BroadcastWidgetStudioFontControls(
                configuration: $configuration,
                titleLabel: "Fuente cuenta regresiva",
                includeSubtitle: false
            )
        }
    }
}
