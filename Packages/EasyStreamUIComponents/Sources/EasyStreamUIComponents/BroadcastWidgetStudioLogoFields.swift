import SwiftUI
import EasyStreamCore

struct BroadcastWidgetStudioLogoFields: View {
    @Binding var configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let onImportLogo: () -> Void
    let onImportLogoFromPhotoLibrary: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BroadcastWidgetStudioLogoImportControl(
                logoURL: logoURL,
                onImportLogo: onImportLogo,
                onImportLogoFromPhotoLibrary: onImportLogoFromPhotoLibrary
            )

            Picker("Animación", selection: $configuration.logoAnimation) {
                ForEach(BroadcastLogoAnimation.allCases, id: \.self) { animation in
                    Text(animation.displayName).tag(animation)
                }
            }
#if os(macOS)
            .pickerStyle(.menu)
#endif

            BroadcastWidgetStudioPlacementSizeControls(configuration: $configuration)

            Stepper(
                "Velocidad: \(String(format: "%.1fx", configuration.animationSpeed))",
                value: $configuration.animationSpeed,
                in: 0.25...3,
                step: 0.25
            )

            Text("Las animaciones corren en ráfagas con pausa (idle) entre ciclos.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
        }
    }
}
