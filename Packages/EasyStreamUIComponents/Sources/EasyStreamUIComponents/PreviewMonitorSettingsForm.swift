import SwiftUI
import EasyStreamCore

public struct PreviewMonitorSettingsForm: View {
    @Binding var settings: PreviewMonitorSettings
    let onOpenMonitor: () -> Void

    public init(settings: Binding<PreviewMonitorSettings>, onOpenMonitor: @escaping () -> Void) {
        _settings = settings
        self.onOpenMonitor = onOpenMonitor
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Abre un grid en otra pantalla para ver todas las cámaras.")
                    .font(.subheadline)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onOpenMonitor) {
                    Label("Abrir monitor ahora", systemImage: "display.2")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))

                DirectorInspectorSection("Distribución", systemImage: "rectangle.grid.2x2") {
                    Picker("Distribución", selection: $settings.layoutMode) {
                        ForEach(PreviewMonitorLayoutMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                DirectorInspectorSection("Pantalla", systemImage: "display") {
                    VStack(alignment: .leading, spacing: 12) {
#if os(iOS)
                        PreviewMonitorExternalDisplayStatus()
#endif
                        PreviewMonitorToggleRow(
                            title: "Abrir en segunda pantalla",
                            isOn: $settings.openOnExternalDisplay
                        )
                        PreviewMonitorToggleRow(
                            title: "Paginar automáticamente",
                            isOn: $settings.autoPaginate
                        )
                        if settings.autoPaginate {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Intervalo")
                                    .font(.subheadline)
                                    .foregroundStyle(BroadcastTheme.primaryText)
                                HStack(spacing: 12) {
                                    Slider(value: $settings.pageIntervalSeconds, in: 3...15, step: 1)
                                    Text("\(Int(settings.pageIntervalSeconds)) s")
                                        .font(.body.monospacedDigit())
                                        .frame(width: 44, alignment: .trailing)
                                }
                            }
                        }
                    }
                }

                DirectorInspectorSection("Información en cada cámara", systemImage: "text.below.photo") {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 280), spacing: 12, alignment: .leading)],
                        alignment: .leading,
                        spacing: 8
                    ) {
                        overlayToggle("Nombre de cámara", keyPath: \.showCameraName)
                        overlayToggle("Índice de fuente", keyPath: \.showSourceIndex)
                        overlayToggle("Tally PVW/PRG/AUDIO", keyPath: \.showTallyBadges)
                        overlayToggle("Resaltar preview", keyPath: \.highlightPreviewSource)
                        overlayToggle("Resaltar programa", keyPath: \.highlightProgramSource)
                        overlayToggle("Estado de conexión", keyPath: \.showConnectionStatus)
                        overlayToggle("Indicador de audio", keyPath: \.showAudioIndicator)
                        overlayToggle("Guías de safe area", keyPath: \.showSafeAreaGuides)
                        overlayToggle("Programa grande en grid", keyPath: \.showProgramInGrid)
                    }
                }

                DirectorInspectorSection("Separación", systemImage: "square.dashed") {
                    HStack(spacing: 12) {
                        Slider(value: $settings.appearance.cellGap, in: 0...12, step: 1)
                        Text("\(Int(settings.appearance.cellGap)) pt")
                            .font(.body.monospacedDigit())
                            .frame(width: 52, alignment: .trailing)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func overlayToggle(
        _ title: String,
        keyPath: WritableKeyPath<PreviewMonitorOverlayOptions, Bool>
    ) -> some View {
        PreviewMonitorToggleRow(
            title: title,
            isOn: Binding(
                get: { settings.overlays[keyPath: keyPath] },
                set: { settings.overlays[keyPath: keyPath] = $0 }
            )
        )
    }
}

private struct PreviewMonitorToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(title, isOn: $isOn)
            .font(.subheadline)
            .toggleStyle(.switch)
            .tint(BroadcastTheme.studioAccent)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if os(iOS)
private struct PreviewMonitorExternalDisplayStatus: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if ProgramOutputDisplayDiscovery.hasExternalDisplay {
                ForEach(ProgramOutputDisplayDiscovery.availableScreens().filter { !$0.isBuiltIn }) { screen in
                    LabeledContent(screen.name) {
                        Text("\(screen.width)×\(screen.height)")
                            .font(.body.monospacedDigit())
                            .foregroundStyle(BroadcastTheme.subtleText)
                    }
                }

                if ProgramOutputDisplayDiscovery.isExternalDisplayMirroring {
                    Label {
                        Text("Duplicación activa: el monitor no será independiente. En Ajustes del iPad → Pantalla, elige «Extender».")
                            .font(.subheadline)
                            .foregroundStyle(BroadcastTheme.subtleText)
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                }
            } else {
                Text("Conecta un monitor por USB-C o HDMI. Si no aparece, revisa el cable o el adaptador.")
                    .font(.subheadline)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("Para un monitor independiente, usa «Extender pantalla» y no «Duplicar».")
                .font(.subheadline)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
#endif
