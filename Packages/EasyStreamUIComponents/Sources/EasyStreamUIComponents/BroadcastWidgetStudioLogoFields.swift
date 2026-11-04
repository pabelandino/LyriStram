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

            Toggle("Rotación horizontal", isOn: Binding(
                get: { configuration.logoAnimation != .none },
                set: { configuration.logoAnimation = $0 ? .sphere3D : .none }
            ))

            BroadcastWidgetStudioPlacementSizeControls(configuration: $configuration)

            if configuration.logoAnimation != .none {
                Stepper(
                    "Velocidad: \(String(format: "%.1fx", configuration.animationSpeed))",
                    value: $configuration.animationSpeed,
                    in: 0.25...3,
                    step: 0.25
                )

                Text("Gira en horizontal, hace una pausa y vuelve a girar. Play la reinicia en esta vista.")
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
        }
    }
}
