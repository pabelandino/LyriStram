import SwiftUI
import EasyStreamCore
import WebRTC
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct CameraSourceTile: View {
    let name: String
    let sourceID: CameraSourceID?
    let track: RTCVideoTrack?
    let hasVideoSignal: Bool
    let connectionState: StreamConnectionState
    let isPreview: Bool
    let isProgram: Bool
    let onSelect: () -> Void

    public init(
        name: String,
        sourceID: CameraSourceID? = nil,
        track: RTCVideoTrack?,
        hasVideoSignal: Bool = true,
        connectionState: StreamConnectionState,
        isPreview: Bool,
        isProgram: Bool,
        onSelect: @escaping () -> Void
    ) {
        self.name = name
        self.sourceID = sourceID
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
            sourceID: nil,
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
                    TileStreamSizeBadge(
                        trackId: track.trackId,
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
        if showsDisconnectedState { parts.append(disconnectedMessage) }
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
        if showsDisconnectedState {
            disconnectedPlaceholder
        } else if let track, connectionState == .connected {
            DirectorCameraTileVideoSurface(track: track)
        } else if showsTileSnapshot, let sourceID {
            DirectorTileThumbnailView(sourceID: sourceID)
        } else {
            ZStack {
                Color.black.opacity(0.85)
                VStack(spacing: 6) {
                    Image(systemName: placeholderSymbolName)
                    Text(placeholderMessage)
                        .font(.caption2)
                    if showsConnectionProgress {
                        BroadcastConnectionProgressBar(
                            progress: BroadcastConnectionProgress.fraction(streamState: connectionState),
                            tint: BroadcastConnectionProgress.tint(streamState: connectionState),
                            height: 3
                        )
                        .frame(maxWidth: 96)
                        .padding(.top, 2)
                    }
                }
                .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    private var showsDisconnectedState: Bool {
        connectionState == .disconnected || connectionState == .failed
    }

    private var disconnectedPlaceholder: some View {
        ZStack {
            Color.black.opacity(0.92)
            VStack(spacing: 8) {
                Image(systemName: disconnectedSymbolName)
                    .font(.title3.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                Text(disconnectedMessage)
                    .font(.caption2.weight(.semibold))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(disconnectedForeground)
            .padding(.horizontal, 8)
        }
    }

    private var disconnectedSymbolName: String {
        switch connectionState {
        case .failed: "exclamationmark.triangle.fill"
        default: "video.slash.fill"
        }
    }

    private var disconnectedMessage: String {
        switch connectionState {
        case .failed: "Conexión fallida"
        default: "Cámara desconectada"
        }
    }

    private var disconnectedForeground: Color {
        switch connectionState {
        case .failed: Color.orange.opacity(0.85)
        default: Color.white.opacity(0.62)
        }
    }

    private var showsConnectionProgress: Bool {
        connectionState == .connecting || connectionState == .signaling
    }

    /// Idle tiles only — preview/program use live decoders.
    private var showsTileSnapshot: Bool {
        guard let sourceID, connectionState == .connected, !isPreview, !isProgram else { return false }
        return DirectorTileThumbnailView.hasThumbnail(for: sourceID)
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

/// Isolated decode-size badge — avoids observing the global store from every tile.
private struct TileStreamSizeBadge: View {
    let trackId: String
    let tint: Color

    var body: some View {
        TimelineView(.periodic(from: .now, by: 2.0)) { _ in
            BroadcastLiveStreamSizeBadge(
                LiveVideoStreamSizeStore.shared.label(forTrackId: trackId),
                tint: tint
            )
        }
    }
}
