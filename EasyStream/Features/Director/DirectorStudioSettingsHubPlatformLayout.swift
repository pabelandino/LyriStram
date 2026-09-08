import SwiftUI

/// Routes hub chrome to the platform layout implementation visible to the compiler and SourceKit.
enum DirectorStudioSettingsHubPlatformLayout {
    @ViewBuilder
    static func content(
        selectedTab: Binding<DirectorStudioSettingsTab>,
        horizontalSizeClass: UserInterfaceSizeClass?,
        @ViewBuilder detailContent: @escaping (DirectorStudioSettingsTab) -> some View
    ) -> some View {
#if os(iOS)
        DirectorStudioSettingsHubIOSLayout(
            selectedTab: selectedTab,
            horizontalSizeClass: horizontalSizeClass,
            detailContent: detailContent
        )
#elseif os(macOS)
        DirectorStudioSettingsHubMacLayout(
            selectedTab: selectedTab,
            detailContent: detailContent
        )
#else
        ContentUnavailableView(
            "Plataforma no soportada",
            systemImage: "gearshape",
            description: Text("Los ajustes del estudio no están disponibles en esta plataforma.")
        )
#endif
    }
}

#if !os(iOS) && !os(macOS)
extension View {
    @ViewBuilder
    func directorStudioSettingsHubWindowSizing() -> some View {
        self
    }
}
#endif
