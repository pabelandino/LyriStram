import LvoqStreamCore
import SwiftUI
import LvoqStreamUIComponents

/// Play, pause, and stop for the video plate. Director monitor only.
struct DirectorProgramVideoTransportOverlay: View {
    private var transport: BroadcastProgramPlateTransport { .shared }

    var body: some View {
        HStack(spacing: 4) {
            Button(action: transport.playOrPause) {
                Image(systemName: transport.isPlaying ? "pause.fill" : "play.fill")
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(transport.isPlaying ? "Pausa" : BundleLocalization.string("Reproducir"))
            .accessibilityLabel(transport.isPlaying ? "Pausa" : BundleLocalization.string("Reproducir"))

            Button(action: transport.stop) {
                Image(systemName: "stop.fill")
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(BundleLocalization.string("Detener"))
            .accessibilityLabel(BundleLocalization.string("Detener"))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .background(.black.opacity(0.55), in: Capsule())
        .padding(.bottom, 12)
    }
}
