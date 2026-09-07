import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Isolated quality editor — draft changes apply only on confirm so PROG stays untouched while browsing presets.
struct DirectorVideoQualitySettingsView: View {
    let initialSettings: DirectorMonitorQualitySettings
    let onApply: (DirectorMonitorQualitySettings) -> Void
    let onCancel: () -> Void

    @State private var draftSettings: DirectorMonitorQualitySettings

    init(
        initialSettings: DirectorMonitorQualitySettings,
        onApply: @escaping (DirectorMonitorQualitySettings) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialSettings = initialSettings
        self.onApply = onApply
        self.onCancel = onCancel
        _draftSettings = State(initialValue: initialSettings)
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 14) {
                    BroadcastSettingsInfoCallout(
                        text: "Los cambios se aplican al pulsar «Listo». El monitor PROG y la salida al aire no se modifican mientras ajustas los menús."
                    )

                    DirectorVideoQualityPanel(settings: $draftSettings)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(BroadcastTheme.panelBackground)
            .broadcastStudioChrome()
            .navigationTitle("Calidad de video")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        onApply(draftSettings)
                    }
                    .disabled(draftSettings == initialSettings)
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 460, minHeight: 620)
#endif
    }
}

/// macOS-only info callout exposed for reuse in the quality panel header.
private struct BroadcastSettingsInfoCallout: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)
                .padding(.top, 1)

            Text(text)
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 2)
    }
}

#if os(macOS)
struct DirectorVideoQualityWindowView: View {
    @Bindable private var session = DirectorWorkspaceSession.shared
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        Group {
            if let viewModel = session.sessionViewModel {
                DirectorVideoQualitySettingsView(
                    initialSettings: viewModel.monitorQuality,
                    onApply: { settings in
                        viewModel.applyMonitorQuality(settings)
                        dismissWindow(id: "director-video-quality")
                    },
                    onCancel: {
                        dismissWindow(id: "director-video-quality")
                    }
                )
            } else {
                ContentUnavailableView(
                    "Director no activo",
                    systemImage: "video.slash",
                    description: Text("Abre una sesión de director para ajustar la calidad de video.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BroadcastTheme.panelBackground)
            }
        }
    }
}
#endif
