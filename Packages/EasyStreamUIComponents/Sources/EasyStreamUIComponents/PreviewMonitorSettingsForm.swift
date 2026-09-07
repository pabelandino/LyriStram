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
        Form {
            Section {
                Text("Abre un grid profesional en otra pantalla para ver todas las cámaras.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)

                Button(action: onOpenMonitor) {
                    Label("Abrir monitor ahora", systemImage: "display.2")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Section("Layout") {
                Picker("Distribución", selection: $settings.layoutMode) {
                    ForEach(PreviewMonitorLayoutMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Pantalla") {
                Toggle("Abrir en segunda pantalla", isOn: $settings.openOnExternalDisplay)
                Toggle("Paginar automáticamente", isOn: $settings.autoPaginate)

                if settings.autoPaginate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Intervalo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            Slider(value: $settings.pageIntervalSeconds, in: 3...15, step: 1)
                            Text("\(Int(settings.pageIntervalSeconds))s")
                                .font(.caption.monospacedDigit())
                                .frame(width: 32, alignment: .trailing)
                        }
                    }
                }
            }

            Section("Overlays") {
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

            Section("Colores tally") {
                colorPresetRow("Preview", color: .previewGreen) {
                    settings.appearance.previewBorder = .previewGreen
                }
                colorPresetRow("Programa", color: .programRed) {
                    settings.appearance.programBorder = .programRed
                }
                colorPresetRow("Audio", color: .audioGold) {
                    settings.appearance.audioAccent = .audioGold
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Separación")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        Slider(value: $settings.appearance.cellGap, in: 0...12, step: 1)
                        Text("\(Int(settings.appearance.cellGap))pt")
                            .font(.caption.monospacedDigit())
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
#if os(iOS)
        .formStyle(.grouped)
#endif
    }

    private func overlayToggle(_ title: String, keyPath: WritableKeyPath<PreviewMonitorOverlayOptions, Bool>) -> some View {
        Toggle(title, isOn: Binding(
            get: { settings.overlays[keyPath: keyPath] },
            set: { settings.overlays[keyPath: keyPath] = $0 }
        ))
    }

    private func colorPresetRow(_ title: String, color: PreviewMonitorRGBColor, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(color.swiftUIColor)
                    .frame(width: 14, height: 14)
                Text(title)
                Spacer()
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

/// Legacy alias — use `PreviewMonitorInspectorSummary` + `PreviewMonitorSettingsSheet`.
