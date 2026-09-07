import SwiftUI
import EasyStreamCore
import WebRTC

public struct CameraSourceTile: View {
    let name: String
    let track: RTCVideoTrack?
    let hasVideoSignal: Bool
    let connectionState: StreamConnectionState
    let isPreview: Bool
    let isProgram: Bool
    let onSelect: () -> Void

    @Bindable private var streamSizes = LiveVideoStreamSizeStore.shared

    public init(
        name: String,
        track: RTCVideoTrack?,
        hasVideoSignal: Bool = true,
        connectionState: StreamConnectionState,
        isPreview: Bool,
        isProgram: Bool,
        onSelect: @escaping () -> Void
    ) {
        self.name = name
        self.track = track
        self.hasVideoSignal = hasVideoSignal
        self.connectionState = connectionState
        self.isPreview = isPreview
        self.isProgram = isProgram
        self.onSelect = onSelect
    }

    /// Backward-compatible initializer when callers only know connected vs not.
    public init(
        name: String,
        track: RTCVideoTrack?,
        isPreview: Bool,
        isProgram: Bool,
        isConnected: Bool,
        onSelect: @escaping () -> Void
    ) {
        self.init(
            name: name,
            track: track,
            hasVideoSignal: track != nil,
            connectionState: isConnected ? .connected : .disconnected,
            isPreview: isPreview,
            isProgram: isProgram,
            onSelect: onSelect
        )
    }

    public var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .topLeading) {
                videoContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(borderColor, lineWidth: isProgram || isPreview ? 3 : 1)
                    }

                HStack(spacing: 6) {
                    Text(name)
                        .font(.caption2.weight(.semibold))
                    if isProgram {
                        Text(BroadcastTerminology.programShort)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(BroadcastTheme.programRed, in: Capsule())
                    } else if isPreview {
                        Text(BroadcastTerminology.previewShort)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(BroadcastTheme.previewGreen, in: Capsule())
                    }
                }
                .padding(8)
                .foregroundStyle(.white)
                .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))
                .padding(8)

                if let track {
                    BroadcastLiveStreamSizeBadge(
                        streamSizes.label(forTrackId: track.trackId),
                        tint: isPreview ? BroadcastTheme.previewGreen : BroadcastTheme.subtleText
                    )
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isPreview ? .isSelected : [])
    }

    private var accessibilityLabel: String {
        var parts = [name]
        if isProgram { parts.append(BroadcastTerminology.programName) }
        if isPreview { parts.append(BroadcastTerminology.previewName) }
        return parts.joined(separator: ", ")
    }

    private var accessibilityHint: String {
        if isProgram, hasVideoSignal {
            return "Al aire en programa. Selecciona otra cámara para preview."
        }
        return "Seleccionar como \(BroadcastTerminology.previewName.lowercased())"
    }

    @ViewBuilder
    private var videoContent: some View {
        if let track {
            DirectorCameraTileVideoSurface(track: track)
        } else {
            ZStack {
                Color.black.opacity(0.85)
                VStack(spacing: 6) {
                    Image(systemName: placeholderSymbolName)
                    Text(placeholderMessage)
                        .font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    private var placeholderSymbolName: String {
        switch connectionState {
        case .connected:
            return "pause.circle"
        case .connecting, .signaling:
            return "video"
        default:
            return "video.slash"
        }
    }

    private var placeholderMessage: String {
        switch connectionState {
        case .connected:
            if isProgram, hasVideoSignal {
                return "Al aire en PROG"
            }
            if hasVideoSignal, !isPreview {
                return "Toca para preview"
            }
            return "En espera"
        case .connecting, .signaling:
            return "Conectando…"
        default:
            return "Sin señal"
        }
    }

    private var borderColor: Color {
        if isProgram { BroadcastTheme.programRed }
        else if isPreview { BroadcastTheme.previewGreen }
        else { BroadcastTheme.panelBorder }
    }
}
