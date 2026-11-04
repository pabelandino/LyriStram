import SwiftUI
import EasyStreamCore

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
            BroadcastSettingsInfoCallout(
                text: "Este preset se guarda para la salida en vivo. YouTube y Facebook lo usarán cuando estén conectados. No cambia la imagen del director."
            )

            BroadcastQualityDropdown(
                title: "Salida en vivo",
                systemImage: "dot.radiowaves.up.forward",
                options: StreamOutputPreset.allCases,
                selection: $settings.outputPreset,
                label: { $0.title },
                chips: { outputChips(for: $0) },
                tags: { $0.platforms }
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
