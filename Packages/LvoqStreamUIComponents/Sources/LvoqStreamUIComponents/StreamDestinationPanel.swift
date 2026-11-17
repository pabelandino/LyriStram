import SwiftUI
import LvoqStreamCore

public struct StreamDestinationPanel: View {
    @Binding var destination: StreamDestination
    let publisherStats: StreamPublisherStats
    let isPublishing: Bool
    let onStart: () -> Void
    let onStop: () -> Void

    public init(
        destination: Binding<StreamDestination>,
        publisherStats: StreamPublisherStats,
        isPublishing: Bool,
        onStart: @escaping () -> Void,
        onStop: @escaping () -> Void
    ) {
        _destination = destination
        self.publisherStats = publisherStats
        self.isPublishing = isPublishing
        self.onStart = onStart
        self.onStop = onStop
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BroadcastFormField("URL del servidor", text: $destination.serverURL, placeholder: "rtmps://servidor/app")
            BroadcastFormField("Nombre del stream", text: $destination.streamName, placeholder: "lvoqstream")

            if isPublishing {
                Button(role: .destructive, action: onStop) {
                    Label(BundleLocalization.string("stream.stop_broadcast"), systemImage: "stop.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.programRed, isProminent: true))
            } else {
                Button(action: onStart) {
                    Label(BundleLocalization.string("stream.start_rtmps"), systemImage: "dot.radiowaves.up.forward")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.liveAmber, isProminent: true))
                .disabled(!destination.isConfigured)
            }

            publisherStatus
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var publisherStatus: some View {
        switch publisherStats.state {
        case .idle, .stopped:
            Text(BundleLocalization.string("Configura RTMP manualmente o prepara una transmisión de Facebook."))
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)
        case .connecting:
            Label(BundleLocalization.string("stream.connecting"), systemImage: "arrow.triangle.2.circlepath")
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)
        case .publishing:
            Text(
                String(
                    format: BundleLocalization.string("stream.sending_stats"),
                    publisherStats.videoFramesSent,
                    publisherStats.audioPacketsSent,
                    formatBytes(publisherStats.bytesSent)
                )
            )
                .font(.caption.monospacedDigit())
                .foregroundStyle(.green)
        case .failed:
            Text(BundleLocalization.string("Error de emisión"))
                .font(.caption)
                .foregroundStyle(.red)
        }
    }

    private func formatBytes(_ bytes: Int) -> String {
        if bytes >= 1_000_000 {
            return String(format: "%.1f MB", Double(bytes) / 1_000_000)
        }
        if bytes >= 1_000 {
            return String(format: "%.0f KB", Double(bytes) / 1_000)
        }
        return "\(bytes) B"
    }
}
