import SwiftUI
import EasyStreamCore

public struct DirectorSourceListRow: View {
    let name: String
    let platform: DevicePlatform
    let isPreview: Bool
    let isProgram: Bool
    let isAudio: Bool
    let isConnected: Bool
    let connectionState: StreamConnectionState
    let signalLevel: Int
    let isSelected: Bool
    let onSelect: () -> Void
    let onReconnect: (() -> Void)?

    public init(
        name: String,
        platform: DevicePlatform = .unknown,
        isPreview: Bool,
        isProgram: Bool,
        isAudio: Bool,
        isConnected: Bool,
        connectionState: StreamConnectionState = .connected,
        signalLevel: Int = 4,
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        onReconnect: (() -> Void)? = nil
    ) {
        self.name = name
        self.platform = platform
        self.isPreview = isPreview
        self.isProgram = isProgram
        self.isAudio = isAudio
        self.isConnected = isConnected
        self.connectionState = connectionState
        self.signalLevel = signalLevel
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onReconnect = onReconnect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onSelect) {
                HStack(alignment: .top, spacing: 12) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(accentBarColor)
                        .frame(width: 4)
                        .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top, spacing: 8) {
                            CameraPlatformBrandIcon(platform: platform, size: 18)
                            Text(name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(BroadcastTheme.primaryText)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            SignalStrengthView(level: signalLevel)
                        }

                        if isPreview || isProgram || isAudio {
                            HStack(spacing: 6) {
                                if isPreview {
                                    BroadcastTallyPill(BroadcastTerminology.previewShort, color: BroadcastTheme.previewGreen)
                                }
                                if isProgram {
                                    BroadcastTallyPill(BroadcastTerminology.programShort, color: BroadcastTheme.programRed)
                                }
                                if isAudio {
                                    BroadcastTallyPill(BroadcastTerminology.audioShort, color: BroadcastTheme.audioGold)
                                }
                            }
                        }

                        if showsConnectionProgress {
                            BroadcastConnectionProgressBar(
                                progress: BroadcastConnectionProgress.fraction(streamState: connectionState),
                                tint: BroadcastConnectionProgress.tint(streamState: connectionState),
                                height: 3
                            )
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            if !isConnected, let onReconnect {
                Button("Reconectar", systemImage: "arrow.clockwise.circle.fill", action: onReconnect)
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(BroadcastTheme.studioAccent)
                    .buttonStyle(.plain)
                    .help("Reconectar cámara")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(rowBorder, lineWidth: isSelected ? 1.5 : 1)
        }
    }

    private var showsConnectionProgress: Bool {
        connectionState == .connecting || connectionState == .signaling
    }

    private var accentBarColor: Color {
        if isProgram { return BroadcastTheme.programRed }
        if isPreview { return BroadcastTheme.previewGreen }
        return Color.white.opacity(0.15)
    }

    private var rowBackground: Color {
        BroadcastTheme.panelElevated.opacity(isSelected ? 0.95 : 0.55)
    }

    private var rowBorder: Color {
        if isSelected { return BroadcastTheme.previewGreen.opacity(0.55) }
        return BroadcastTheme.panelBorder
    }
}
