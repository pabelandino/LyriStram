import SwiftUI
import EasyStreamCore
import WebRTC

public struct PreviewMonitorCellView: View {
    let camera: PreviewMonitorCamera
    let displayTrack: RTCVideoTrack?
    let settings: PreviewMonitorSettings
    let isPreview: Bool
    let isProgram: Bool
    let isAudio: Bool
    let onSelect: (CameraSourceID) -> Void

    public init(
        camera: PreviewMonitorCamera,
        displayTrack: RTCVideoTrack? = nil,
        settings: PreviewMonitorSettings,
        isPreview: Bool,
        isProgram: Bool,
        isAudio: Bool,
        onSelect: @escaping (CameraSourceID) -> Void
    ) {
        self.camera = camera
        self.displayTrack = displayTrack
        self.settings = settings
        self.isPreview = isPreview
        self.isProgram = isProgram
        self.isAudio = isAudio
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            onSelect(camera.id)
        } label: {
            ZStack {
                videoLayer
                overlayLayer
                if settings.overlays.showSafeAreaGuides {
                    safeAreaGuides
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: settings.appearance.borderWidth)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var videoLayer: some View {
        // Never fall back to camera.track — decodes every source and freezes the director UI.
        let liveTrack = camera.isConnected ? displayTrack : nil
        ZStack {
            Color.black
            if camera.isConnected {
                PreviewMonitorStableVideoSlot(sourceID: camera.id, track: liveTrack)
            }
            if !camera.isConnected {
                disconnectedLayer
            } else if liveTrack == nil {
                if showsTileSnapshot {
                    DirectorTileThumbnailView(sourceID: camera.id)
                } else {
                    idleLayer
                }
            }
        }
    }

    private var disconnectedLayer: some View {
        ZStack {
            Color.black.opacity(0.92)
            VStack(spacing: 8) {
                Image(systemName: "video.slash.fill")
                    .font(.title3.weight(.semibold))
                Text("Cámara desconectada")
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(.white.opacity(0.62))
        }
    }

    private var idleLayer: some View {
        ZStack {
            Color.black.opacity(0.9)
            VStack(spacing: 6) {
                Image(systemName: camera.isConnected ? "pause.circle" : "video")
                Text(camera.isConnected ? "En espera" : "Conectando…")
                    .font(.caption2)
            }
            .foregroundStyle(.white.opacity(0.55))
        }
    }

    /// Idle cells only — preview/program use live decoders on the multiview monitor.
    private var showsTileSnapshot: Bool {
        camera.isConnected
            && !isPreview
            && !isProgram
            && DirectorTileThumbnailView.hasThumbnail(for: camera.id)
    }

    private var overlayLayer: some View {
        VStack {
            HStack(alignment: .top) {
                leadingLabels
                Spacer()
                tallyBadges
            }
            Spacer()
            bottomBar
        }
        .padding(8)
    }

    @ViewBuilder
    private var leadingLabels: some View {
        VStack(alignment: .leading, spacing: 4) {
            if settings.overlays.showSourceIndex {
                Text(String(format: "%02d", camera.sourceIndex + 1))
                    .font(.caption.weight(.heavy).monospacedDigit())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 4))
            }
            if settings.overlays.showCameraName {
                Text(camera.displayName)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 4))
            }
        }
        .foregroundStyle(.white)
    }

    @ViewBuilder
    private var tallyBadges: some View {
        if settings.overlays.showTallyBadges {
            VStack(alignment: .trailing, spacing: 4) {
                if isProgram && settings.overlays.highlightProgramSource {
                    tallyBadge(BroadcastTerminology.programShort, color: settings.appearance.programBorder.swiftUIColor)
                }
                if isPreview && settings.overlays.highlightPreviewSource {
                    tallyBadge(BroadcastTerminology.previewShort, color: settings.appearance.previewBorder.swiftUIColor)
                }
                if isAudio && settings.overlays.showAudioIndicator {
                    tallyBadge(BroadcastTerminology.audioShort, color: settings.appearance.audioAccent.swiftUIColor)
                }
            }
        }
    }

    @ViewBuilder
    private var bottomBar: some View {
        HStack {
            if settings.overlays.showConnectionStatus {
                Label(
                    camera.isConnected ? "Live" : "Offline",
                    systemImage: camera.isConnected ? "dot.radiowaves.left.and.right" : "exclamationmark.triangle"
                )
                .font(.caption2.weight(.semibold))
                .foregroundStyle(camera.isConnected ? .green : .orange)
            }
            Spacer()
            if settings.overlays.showAudioIndicator && camera.isMuted {
                Label("Mute", systemImage: "mic.slash.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 4))
        .foregroundStyle(.white)
    }

    private var safeAreaGuides: some View {
        GeometryReader { proxy in
            let insetX = proxy.size.width * 0.1
            let insetY = proxy.size.height * 0.1
            Rectangle()
                .strokeBorder(Color.yellow.opacity(0.35), lineWidth: 1)
                .padding(.horizontal, insetX)
                .padding(.vertical, insetY)
        }
        .allowsHitTesting(false)
    }

    private var borderColor: Color {
        if isProgram && settings.overlays.highlightProgramSource {
            return settings.appearance.programBorder.swiftUIColor
        }
        if isPreview && settings.overlays.highlightPreviewSource {
            return settings.appearance.previewBorder.swiftUIColor
        }
        return Color.white.opacity(0.15)
    }

    private func tallyBadge(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.caption2.weight(.black))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color, in: Capsule())
            .foregroundStyle(.white)
    }

}

/// One persistent Metal slot per camera — swaps PREV/PROG roles without NSView teardown.
private struct PreviewMonitorStableVideoSlot: View {
    let sourceID: CameraSourceID
    let track: RTCVideoTrack?

    var body: some View {
        BoundedWebRTCVideoView(track: track, sinkCategory: .previewMonitor)
            .id(sourceID)
            .opacity(track != nil ? 1 : 0)
            .allowsHitTesting(false)
            .animation(nil, value: track.map { ObjectIdentifier($0) })
    }
}
