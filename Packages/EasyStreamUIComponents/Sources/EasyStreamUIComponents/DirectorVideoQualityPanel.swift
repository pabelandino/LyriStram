import SwiftUI
import EasyStreamCore

// MARK: - Settings helpers

private struct BroadcastSettingsToggleRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(BroadcastTheme.liveAmber)
                .frame(width: 28, height: 28)
                .background(BroadcastTheme.liveAmber.opacity(0.14), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BroadcastTheme.primaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Toggle(title, isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(BroadcastTheme.studioAccent)
        }
        .padding(12)
        .background(BroadcastTheme.panelBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

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

// MARK: - Main panel

public struct DirectorVideoQualityPanel: View {
    @Binding var settings: DirectorMonitorQualitySettings

    public init(settings: Binding<DirectorMonitorQualitySettings>) {
        _settings = settings
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            BroadcastSettingsToggleRow(
                title: "Modo ahorro de energía",
                subtitle: "Pausa cámaras idle, desactiva precalentado y baja tiles. No modifica el preset PROG que elijas.",
                systemImage: "leaf.fill",
                isOn: $settings.energySaverMode
            )

            qualitySummaryStrip

            BroadcastQualityDropdown(
                title: "Tiles preview",
                systemImage: "rectangle.grid.2x2.fill",
                options: PreviewTilePreset.allCases,
                selection: $settings.previewPreset,
                label: { $0.title },
                chips: { previewChips(for: $0) }
            )

            BroadcastQualityDropdown(
                title: "Monitor PROG",
                systemImage: "tv.fill",
                options: ProgramMonitorPreset.allCases,
                selection: $settings.progPreset,
                label: { $0.title },
                chips: { progChips(for: $0) }
            )

            Divider().overlay(BroadcastTheme.workspaceDivider)

            BroadcastQualityDropdown(
                title: "Salida en vivo",
                systemImage: "dot.radiowaves.up.forward",
                options: StreamOutputPreset.allCases,
                selection: $settings.outputPreset,
                label: { $0.title },
                chips: { outputChips(for: $0) },
                tags: { $0.platforms }
            )

            Divider().overlay(BroadcastTheme.workspaceDivider)

            BroadcastSettingsToggleRow(
                title: "Pausar cámaras en espera",
                subtitle: "Solo preview y programa envían video. Esencial con 3+ cámaras para evitar que el CPU crezca linealmente.",
                systemImage: "moon.fill",
                isOn: $settings.pauseIdleCameraStreams
            )

            BroadcastSettingsToggleRow(
                title: "Precalentar corte",
                subtitle: "La cámara en preview envía video a resolución PROG y el bus incoming lo decodifica antes del take — cortes instantáneos en HD.",
                systemImage: "bolt.fill",
                isOn: $settings.prefetchTakeTarget
            )

            BroadcastSettingsInfoCallout(
                text: "Off-air solo decodifica el tile de preview — el monitor PROG no usa GPU. Con 3+ cámaras activa «Pausar cámaras en espera»."
            )
        }
    }

    private var qualitySummaryStrip: some View {
        HStack(spacing: 10) {
            summaryTile(
                label: "Tiles",
                value: settings.previewPreset.streamSpec.displayLabel,
                tint: BroadcastTheme.previewGreen
            )
            summaryTile(
                label: "PROG",
                value: settings.progPreset.streamSpec.displayLabel,
                tint: BroadcastTheme.programRed
            )
            summaryTile(
                label: "Salida",
                value: settings.outputPreset.encoderConfiguration.displayLabel,
                tint: BroadcastTheme.studioAccent
            )
        }
    }

    private func summaryTile(label: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(BroadcastTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(tint.opacity(0.22), lineWidth: 1)
        }
    }

    private func previewChips(for preset: PreviewTilePreset) -> [BroadcastSpecChipModel] {
        let spec = preset.streamSpec
        return [
            BroadcastSpecChipModel(spec.resolutionLabel, tint: BroadcastTheme.previewGreen),
            BroadcastSpecChipModel("\(spec.frameRate) fps"),
            BroadcastSpecChipModel(spec.bitrateMbpsLabel)
        ]
    }

    private func progChips(for preset: ProgramMonitorPreset) -> [BroadcastSpecChipModel] {
        let spec = preset.streamSpec
        return [
            BroadcastSpecChipModel(spec.resolutionLabel, tint: BroadcastTheme.programRed),
            BroadcastSpecChipModel("\(spec.frameRate) fps"),
            BroadcastSpecChipModel(spec.bitrateMbpsLabel)
        ]
    }

    private func outputChips(for preset: StreamOutputPreset) -> [BroadcastSpecChipModel] {
        let config = preset.encoderConfiguration
        return [
            BroadcastSpecChipModel(config.resolutionLabel, tint: BroadcastTheme.studioAccent),
            BroadcastSpecChipModel("\(config.frameRate) fps"),
            BroadcastSpecChipModel(config.bitrateMbpsLabel)
        ]
    }
}

/// Backward-compatible alias.
public typealias DirectorMonitorQualityPanel = DirectorVideoQualityPanel

// MARK: - Preset display helpers

extension BroadcastStreamSpec {
    var resolutionLabel: String { "\(width)×\(height)" }
    var bitrateMbpsLabel: String {
        String(format: "%.1f Mbps", Double(maxBitrateBps) / 1_000_000)
    }
}

extension VideoEncoderConfiguration {
    var resolutionLabel: String { "\(width)×\(height)" }
    var bitrateMbpsLabel: String {
        String(format: "%.1f Mbps", Double(averageBitrate) / 1_000_000)
    }
    var displayLabel: String {
        "\(width)×\(height) · \(frameRate) fps"
    }
}
