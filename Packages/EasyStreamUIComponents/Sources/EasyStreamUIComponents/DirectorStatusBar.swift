import SwiftUI
import EasyStreamCore

public struct DirectorStatusBar: View {
    let connectedCameras: Int
    let activeStreamingCameras: Int
    let programName: String?
    let programPresetLabel: String?
    let programTrackId: String?
    let isLive: Bool
    let encoderStats: VideoEncoderStats?
    let audioEncoderStats: AudioEncoderStats?

    public init(
        connectedCameras: Int,
        activeStreamingCameras: Int? = nil,
        programName: String?,
        programPresetLabel: String? = nil,
        programTrackId: String? = nil,
        isLive: Bool,
        encoderStats: VideoEncoderStats? = nil,
        audioEncoderStats: AudioEncoderStats? = nil
    ) {
        self.connectedCameras = connectedCameras
        self.activeStreamingCameras = activeStreamingCameras ?? connectedCameras
        self.programName = programName
        self.programPresetLabel = programPresetLabel
        self.programTrackId = programTrackId
        self.isLive = isLive
        self.encoderStats = encoderStats
        self.audioEncoderStats = audioEncoderStats
    }

    public var body: some View {
        HStack(spacing: 16) {
            Label(isLive ? "EN VIVO" : "PREVIEW", systemImage: "circle.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(isLive ? BroadcastTheme.programRed : BroadcastTheme.liveAmber)

            Text(cameraCountLabel)
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
                    TimelineView(.periodic(from: .now, by: 2.0)) { _ in
                        Text(Self.liveDirectorMonitorLabel(
                            programPresetLabel: programPresetLabel,
                            programTrackId: programTrackId
                        ))
                    }
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

    private var cameraCountLabel: String {
        if activeStreamingCameras < connectedCameras {
            return "\(connectedCameras) conectadas · \(activeStreamingCameras) en stream"
        }
        return "\(connectedCameras) cámara(s)"
    }

    private func formatBitrate(_ kbps: Int) -> String {
        if kbps >= 1000 {
            return String(format: "%.1f Mbps", Double(kbps) / 1000)
        }
        return "\(kbps) kbps"
    }

    private static func liveDirectorMonitorLabel(
        programPresetLabel: String?,
        programTrackId: String?
    ) -> String {
        let snapshot = VideoRendererSinkRegistry.snapshot()
        let sinks = snapshot.totalActiveSinks
        let breakdown = snapshot.countsByCategory
            .filter { $0.value > 0 }
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { "\($0.key.rawValue):\($0.value)" }
            .joined(separator: " ")

        let liveLabel = LiveVideoStreamSizeStore.shared.label(forTrackId: programTrackId)
            ?? metalProgramLiveLabel()

        if let preset = programPresetLabel, let live = liveLabel {
            return "PROG preset \(preset) · vivo \(live) · \(sinks) dec. [\(breakdown)]"
        }
        if let live = liveLabel {
            return "PROG vivo \(live) · \(sinks) dec. [\(breakdown)]"
        }
        if let preset = programPresetLabel {
            return "PROG preset \(preset) · \(sinks) dec. [\(breakdown)]"
        }
        return "PROG — · \(sinks) dec. [\(breakdown)]"
    }

    private static func metalProgramLiveLabel() -> String? {
        let prog = ProgramFrameTelemetryRegistry.live.snapshot().first { $0.busSlot == .programOnAir }
        guard let prog, prog.contentSize.width > 1, prog.contentSize.height > 1 else { return nil }
        return "\(Int(prog.contentSize.width))×\(Int(prog.contentSize.height))"
    }
}
