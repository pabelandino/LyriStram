import SwiftUI
import EasyStreamCore

/// Maps camera/director connection lifecycle to a single 0…1 progress value.
public enum BroadcastConnectionProgress {
    public static func isInProgress(
        streamState: StreamConnectionState,
        statusMessage: String = "",
        isReconnecting: Bool = false
    ) -> Bool {
        if isReconnecting { return true }
        if streamState == .connected { return false }
        if streamState == .connecting || streamState == .signaling { return true }
        if streamState == .failed || streamState == .disconnected { return false }

        let normalized = statusMessage.lowercased()
        if normalized.contains("elige un director") { return false }
        return normalized.contains("iniciando")
            || normalized.contains("buscando")
            || normalized.contains("esperando")
            || normalized.contains("conectando")
            || normalized.contains("negociando")
            || normalized.contains("reconectando")
    }

    public static func fraction(
        streamState: StreamConnectionState,
        statusMessage: String = "",
        isReconnecting: Bool = false
    ) -> CGFloat {
        if streamState == .connected { return 1 }
        if isReconnecting { return 0.68 }

        switch streamState {
        case .signaling:
            return 0.78
        case .connecting:
            return 0.46
        case .idle:
            let normalized = statusMessage.lowercased()
            if normalized.contains("iniciando") { return 0.1 }
            if normalized.contains("negociando") { return 0.78 }
            if normalized.contains("conectando") { return 0.46 }
            if normalized.contains("buscando") || normalized.contains("esperando") { return 0.24 }
            return 0.18
        default:
            return 0.12
        }
    }

    public static func tint(
        streamState: StreamConnectionState,
        statusMessage: String = "",
        isReconnecting: Bool = false
    ) -> Color {
        if isReconnecting { return BroadcastTheme.liveAmber }
        let normalized = statusMessage.lowercased()
        if streamState == .signaling || normalized.contains("negociando") {
            return BroadcastTheme.liveAmber
        }
        if streamState == .connecting || normalized.contains("conectando") {
            return BroadcastTheme.controlAccent
        }
        return BroadcastTheme.studioAccent
    }
}

/// Determinate neon bar — fills left-to-right until connection completes.
public struct BroadcastConnectionProgressBar: View {
    let progress: CGFloat
    let tint: Color
    let height: CGFloat

    public init(progress: CGFloat, tint: Color = BroadcastTheme.studioAccent, height: CGFloat = 5) {
        self.progress = progress
        self.tint = tint
        self.height = height
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = max(geometry.size.width, 1)
            let clamped = min(max(progress, 0), 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.06))
                    .overlay {
                        Capsule()
                            .strokeBorder(tint.opacity(0.28), lineWidth: 1)
                    }

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.55), tint, BroadcastTheme.controlAccent.opacity(0.95)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(height * 2, width * clamped))
                    .shadow(color: tint.opacity(0.55), radius: 5)
            }
            .clipShape(Capsule())
            .animation(.easeInOut(duration: 0.35), value: clamped)
        }
        .frame(height: height)
        .accessibilityLabel("Progreso de conexión")
        .accessibilityValue("\(Int(min(max(progress, 0), 1) * 100)) por ciento")
    }
}
