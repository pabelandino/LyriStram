import SwiftUI
import LvoqStreamCore

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

            Toggle(BundleLocalization.string("Rotación horizontal"), isOn: Binding(
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

                Text(BundleLocalization.string("widget.studio.logo_spin_hint"))
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
        }
    }
}
