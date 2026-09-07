import SwiftUI
import EasyStreamCore

struct DirectorRemoteControlsHeader: View {
    let cameraName: String
    let connectionState: StreamConnectionState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Controles remotos")
                .font(.headline)
            Text(cameraName)
                .font(.subheadline)
                .foregroundStyle(BroadcastTheme.subtleText)
            Text("Los ajustes se guardan automáticamente por cámara.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText.opacity(0.72))

            if connectionState != .connected {
                Text(connectionStateLabel)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
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
