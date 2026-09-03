import SwiftUI
import EasyStreamCore

// MARK: - Shared chips

struct BroadcastSpecChip: View {
    let text: String
    var tint: Color = BroadcastTheme.subtleText

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(tint.opacity(0.95))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(tint.opacity(0.14), in: Capsule())
    }
}

struct BroadcastPlatformTagRow: View {
    let platforms: [BroadcastPlatform]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(platforms, id: \.self) { platform in
                Text(platform.shortLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(platform.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(platform.accentColor.opacity(0.14), in: Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(platform.accentColor.opacity(0.28), lineWidth: 0.5)
                    }
            }
        }
    }
}

// MARK: - Quality picker row

public struct BroadcastQualityDropdown<Option: Identifiable & Hashable>: View {
    let title: String
    let systemImage: String
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String
    let chips: (Option) -> [BroadcastSpecChipModel]
    let tags: (Option) -> [BroadcastPlatform]

    public init(
        title: String,
        systemImage: String,
        options: [Option],
        selection: Binding<Option>,
        label: @escaping (Option) -> String,
        chips: @escaping (Option) -> [BroadcastSpecChipModel],
        tags: @escaping (Option) -> [BroadcastPlatform] = { _ in [] }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.options = options
        _selection = selection
        self.label = label
        self.chips = chips
        self.tags = tags
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(BroadcastTheme.studioAccent)
                    .frame(width: 24, height: 24)
                    .background(BroadcastTheme.studioAccent.opacity(0.14), in: RoundedRectangle(cornerRadius: 6, style: .continuous))

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)
            }

            Menu {
                ForEach(options) { option in
                    Button {
                        selection = option
                    } label: {
                        if option == selection {
                            Label(label(option), systemImage: "checkmark")
                        } else {
                            Text(label(option))
                        }
                    }
                }
            } label: {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(label(selection))
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)

                        BroadcastSpecChipRow(models: chips(selection))
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BroadcastTheme.subtleText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BroadcastTheme.panelBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .menuStyle(.borderlessButton)

            if !tags(selection).isEmpty {
                BroadcastPlatformTagRow(platforms: tags(selection))
                    .padding(.leading, 2)
            }
        }
    }
}

public struct BroadcastSpecChipModel: Hashable {
    public let text: String
    public let tint: Color

    public init(_ text: String, tint: Color = BroadcastTheme.subtleText) {
        self.text = text
        self.tint = tint
    }
}

struct BroadcastSpecChipRow: View {
    let models: [BroadcastSpecChipModel]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(models, id: \.self) { model in
                BroadcastSpecChip(text: model.text, tint: model.tint)
            }
        }
    }
}

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
            qualitySummaryStrip

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
                title: "Precalentar corte",
                subtitle: "Decodifica la cámara de preview antes del take. Usa más CPU pero reduce el retardo al cortar.",
                systemImage: "bolt.fill",
                isOn: $settings.prefetchTakeTarget
            )

            BroadcastSettingsInfoCallout(
                text: "Los tiles de preview usan 640×360 para ahorrar CPU. La salida solo se aplica al publicar en vivo."
            )
        }
    }

    private var qualitySummaryStrip: some View {
        HStack(spacing: 10) {
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
                .foregroundStyle(.primary)
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

extension BroadcastPlatform {
    var accentColor: Color {
        switch self {
        case .youtube: Color(red: 0.95, green: 0.22, blue: 0.18)
        case .facebook: Color(red: 0.28, green: 0.52, blue: 0.96)
        case .rtmp: BroadcastTheme.copper
        }
    }
}

extension BroadcastStreamSpec {
    var resolutionLabel: String { "\(height)p" }
    var bitrateMbpsLabel: String {
        String(format: "%.1f Mbps", Double(maxBitrateBps) / 1_000_000)
    }
}

extension VideoEncoderConfiguration {
    var resolutionLabel: String { "\(height)p" }
    var bitrateMbpsLabel: String {
        String(format: "%.1f Mbps", Double(averageBitrate) / 1_000_000)
    }
    var displayLabel: String {
        "\(width)×\(height) · \(frameRate) fps"
    }
}
