import SwiftUI
import EasyStreamCore
import WebRTC
#if os(iOS)
import UIKit
#endif

public struct DirectorStatusBar: View {
    let connectedCameras: Int
    let programName: String?
    let isLive: Bool
    let encoderStats: VideoEncoderStats?
    let audioEncoderStats: AudioEncoderStats?

    public init(
        connectedCameras: Int,
        programName: String?,
        isLive: Bool,
        encoderStats: VideoEncoderStats? = nil,
        audioEncoderStats: AudioEncoderStats? = nil
    ) {
        self.connectedCameras = connectedCameras
        self.programName = programName
        self.isLive = isLive
        self.encoderStats = encoderStats
        self.audioEncoderStats = audioEncoderStats
    }

    public var body: some View {
        HStack(spacing: 16) {
            Label(isLive ? "EN VIVO" : "PREVIEW", systemImage: "circle.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(isLive ? BroadcastTheme.programRed : BroadcastTheme.liveAmber)

            Text("\(connectedCameras) cámara(s)")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let programName {
                Text("\(BroadcastTerminology.programShort): \(programName)")
                    .font(.caption.weight(.semibold))
            }

            Spacer()

            Group {
                let hasVideo = encoderStats?.isRunning == true && (encoderStats?.framesEncoded ?? 0) > 0
                let hasAudio = audioEncoderStats?.isRunning == true && (audioEncoderStats?.packetsEncoded ?? 0) > 0

                if hasVideo || hasAudio {
                    HStack(spacing: 10) {
                        if hasVideo, let encoderStats {
                            Text("H.264 · \(formatBitrate(encoderStats.estimatedBitrateKbps))")
                        }
                        if hasAudio, let audioEncoderStats {
                            Text("AAC · \(audioEncoderStats.configuredBitrate / 1000) kbps")
                        }
                    }
                } else {
                    Text("1080p · 30fps · AAC")
                }
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(BroadcastTheme.panelElevated)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(BroadcastTheme.workspaceDivider)
                .frame(height: 1)
        }
    }

    private func formatBitrate(_ kbps: Int) -> String {
        if kbps >= 1000 {
            return String(format: "%.1f Mbps", Double(kbps) / 1000)
        }
        return "\(kbps) kbps"
    }
}

public struct CameraSourceTile: View {
    let name: String
    let track: RTCVideoTrack?
    let connectionState: StreamConnectionState
    let isPreview: Bool
    let isProgram: Bool
    let onSelect: () -> Void

    public init(
        name: String,
        track: RTCVideoTrack?,
        connectionState: StreamConnectionState,
        isPreview: Bool,
        isProgram: Bool,
        onSelect: @escaping () -> Void
    ) {
        self.name = name
        self.track = track
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var videoContent: some View {
        if let track {
            BoundedWebRTCVideoView(track: track)
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

public struct TakeToProgramButton: View {
    let isEnabled: Bool
    let action: () -> Void

    @State private var isHovered = false
    @State private var isPressing = false

    public init(isEnabled: Bool, action: @escaping () -> Void) {
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button {
#if os(iOS)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
#endif
            action()
        } label: {
            VStack(spacing: 4) {
                Label(BroadcastTerminology.takeAction, systemImage: "arrow.up.right.square.fill")
                    .font(.headline.weight(.bold))
                Text(BroadcastTerminology.takeDescription)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(BroadcastTakeButtonStyle(isHovered: isHovered, isPressing: isPressing))
        .onHover { isHovered = $0 }
        .simultaneousGesture(pressGesture)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }

    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard isEnabled else { return }
                isPressing = true
            }
            .onEnded { _ in
                isPressing = false
            }
    }
}

// Legacy alias kept for compatibility during UI migration.
public typealias CutButton = TakeToProgramButton

public struct SwitchTransitionControls: View {
    @Binding var transition: SwitchTransition

    public init(transition: Binding<SwitchTransition>) {
        _transition = transition
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Transición")
                .font(.subheadline.weight(.semibold))

            Picker("Tipo", selection: $transition.kind) {
                ForEach(SwitchTransitionKind.allCases) { kind in
                    Text(kind.displayName).tag(kind)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: transition.kind) { _, kind in
                if kind == .cut {
                    transition.duration = 0
                } else if transition.duration <= 0 {
                    transition.duration = SwitchTransition.defaultDuration(for: kind)
                }
            }

            if transition.kind != .cut {
                HStack {
                    Text("Duración")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Slider(value: $transition.duration, in: 0.2...2.0, step: 0.1)
                    Text(String(format: "%.1fs", transition.duration))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 36, alignment: .trailing)
                }
            }
        }
    }
}

public struct TransitionProgramView: View {
    let programTrack: RTCVideoTrack?
    let outgoingTrack: RTCVideoTrack?
    let previewTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let progress: Double
    let kind: SwitchTransitionKind

    public init(
        programTrack: RTCVideoTrack?,
        outgoingTrack: RTCVideoTrack?,
        previewTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        progress: Double,
        kind: SwitchTransitionKind
    ) {
        self.programTrack = programTrack
        self.outgoingTrack = outgoingTrack
        self.previewTrack = previewTrack
        self.isTransitioning = isTransitioning
        self.progress = progress
        self.kind = kind
    }

    /// Backward-compatible entry point for simple two-track wiring.
    public init(
        outgoingTrack: RTCVideoTrack?,
        incomingTrack: RTCVideoTrack?,
        progress: Double,
        kind: SwitchTransitionKind
    ) {
        self.init(
            programTrack: incomingTrack,
            outgoingTrack: outgoingTrack,
            previewTrack: outgoingTrack == nil ? nil : incomingTrack,
            isTransitioning: outgoingTrack != nil,
            progress: progress,
            kind: kind
        )
    }

    public var body: some View {
        ProgramCrossfadeVideoView(
            programTrack: programTrack,
            outgoingTrack: isTransitioning ? outgoingTrack : nil,
            incomingTrack: isTransitioning ? previewTrack : nil,
            isTransitioning: isTransitioning,
            progress: progress,
            kind: kind
        )
        .animation(nil, value: isTransitioning)
        .animation(nil, value: progress)
    }
}

public struct DirectorRemoteControlsView: View {
    let cameraName: String
    let settings: RemoteCameraSettings
    let connectionState: StreamConnectionState
    let onMutedChange: (Bool) -> Void
    let onZoomChange: (Double) -> Void
    let onExposureChange: (Float) -> Void
    let onWhiteBalanceChange: (String) -> Void
    let onLensChange: (String) -> Void
    let onReconnect: () -> Void

    public init(
        cameraName: String,
        settings: RemoteCameraSettings,
        connectionState: StreamConnectionState = .connected,
        onMutedChange: @escaping (Bool) -> Void,
        onZoomChange: @escaping (Double) -> Void,
        onExposureChange: @escaping (Float) -> Void,
        onWhiteBalanceChange: @escaping (String) -> Void,
        onLensChange: @escaping (String) -> Void,
        onReconnect: @escaping () -> Void = {}
    ) {
        self.cameraName = cameraName
        self.settings = settings
        self.connectionState = connectionState
        self.onMutedChange = onMutedChange
        self.onZoomChange = onZoomChange
        self.onExposureChange = onExposureChange
        self.onWhiteBalanceChange = onWhiteBalanceChange
        self.onLensChange = onLensChange
        self.onReconnect = onReconnect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Controles remotos")
                    .font(.headline)
                Text(cameraName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Los ajustes se guardan automáticamente por cámara.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if connectionState != .connected {
                Text(connectionStateLabel)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Button(action: onReconnect) {
                Label(reconnectButtonTitle, systemImage: "arrow.clockwise.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BroadcastGlowButtonStyle(
                tint: connectionState == .connected ? BroadcastTheme.subtleText : BroadcastTheme.studioAccent,
                isProminent: connectionState != .connected
            ))

            Toggle(isOn: Binding(
                get: { settings.isMuted },
                set: { onMutedChange($0) }
            )) {
                Label("Silenciar micrófono", systemImage: settings.isMuted ? "mic.slash.fill" : "mic.fill")
            }
            .toggleStyle(.switch)

            lensPicker
            zoomControl
            exposureControl
            whiteBalancePicker
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var lensPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cámara")
                .font(.subheadline.weight(.semibold))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(RemoteLensOption.allCases) { lens in
                        Button {
                            onLensChange(lens.rawValue)
                        } label: {
                            Text(lens.displayName)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    activeLens == lens ? BroadcastTheme.studioAccent : Color.secondary.opacity(0.15),
                                    in: Capsule()
                                )
                                .foregroundStyle(activeLens == lens ? Color.white : Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var zoomControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Zoom")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(String(format: "%.1fx", settings.zoomFactor))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(
                value: Binding(
                    get: { settings.zoomFactor },
                    set: { onZoomChange($0) }
                ),
                in: 1...10
            )
        }
    }

    private var exposureControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Exposición")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(String(format: "%+.1f EV", settings.exposureBias))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(
                value: Binding(
                    get: { Double(settings.exposureBias) },
                    set: { onExposureChange(Float($0)) }
                ),
                in: -2...2
            )
        }
    }

    private var whiteBalancePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Balance de blancos")
                .font(.subheadline.weight(.semibold))
            Picker("Balance de blancos", selection: Binding(
                get: { RemoteWhiteBalanceOption(rawValue: settings.whiteBalance) ?? .auto },
                set: { onWhiteBalanceChange($0.rawValue) }
            )) {
                ForEach(RemoteWhiteBalanceOption.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var activeLens: RemoteLensOption {
        RemoteLensOption(rawValue: settings.activeLens) ?? .wide
    }

    private var reconnectButtonTitle: String {
        connectionState == .connected ? "Forzar reconexión" : "Reconectar cámara"
    }

    private var connectionStateLabel: String {
        switch connectionState {
        case .connecting, .signaling: "Conectando…"
        case .failed: "Conexión fallida"
        case .disconnected: "Desconectada"
        default: "Sin señal de video"
        }
    }
}
