import SwiftUI
import EasyStreamCore

/// Indeterminate neon progress — used while the camera discovers or negotiates with the Director.
public struct BroadcastNeonProgressBar: View {
    let tint: Color
    let height: CGFloat

    @State private var sweepPhase: CGFloat = 0

    public init(tint: Color = BroadcastTheme.studioAccent, height: CGFloat = 4) {
        self.tint = tint
        self.height = height
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = max(geometry.size.width, 1)
            let segmentWidth = width * 0.42

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.05))
                    .overlay {
                        Capsule()
                            .strokeBorder(tint.opacity(0.28), lineWidth: 1)
                    }

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                tint.opacity(0.05),
                                tint.opacity(0.95),
                                BroadcastTheme.controlAccent.opacity(0.9),
                                tint.opacity(0.05)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: segmentWidth)
                    .shadow(color: tint.opacity(0.75), radius: 6)
                    .shadow(color: tint.opacity(0.35), radius: 12)
                    .offset(x: sweepPhase * (width + segmentWidth) - segmentWidth)
            }
            .clipShape(Capsule())
        }
        .frame(height: height)
        .accessibilityLabel("Conectando")
        .accessibilityAddTraits(.updatesFrequently)
        .onAppear {
            sweepPhase = 0
            withAnimation(.linear(duration: 1.35).repeatForever(autoreverses: false)) {
                sweepPhase = 1
            }
        }
    }
}

public enum BroadcastConnectionLoadingIndicator {
    public static func showsProgress(
        streamState: StreamConnectionState,
        statusMessage: String,
        isReconnecting: Bool
    ) -> Bool {
        if isReconnecting { return true }
        switch streamState {
        case .connecting, .signaling:
            return true
        case .idle:
            let normalized = statusMessage.lowercased()
            return normalized.contains("buscando")
                || normalized.contains("esperando")
                || normalized.contains("conectando")
                || normalized.contains("negociando")
                || normalized.contains("reconectando")
        default:
            return false
        }
    }

    public static func tint(
        streamState: StreamConnectionState,
        statusMessage: String,
        isReconnecting: Bool
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

/// Status copy + optional neon bar for camera / director connection panels.
public struct BroadcastConnectionStatusLine: View {
    let message: String
    let streamState: StreamConnectionState
    let isReconnecting: Bool
    let font: Font

    public init(
        message: String,
        streamState: StreamConnectionState,
        isReconnecting: Bool = false,
        font: Font = .caption
    ) {
        self.message = message
        self.streamState = streamState
        self.isReconnecting = isReconnecting
        self.font = font
    }

    private var showsBar: Bool {
        BroadcastConnectionLoadingIndicator.showsProgress(
            streamState: streamState,
            statusMessage: message,
            isReconnecting: isReconnecting
        )
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(message)
                .font(font)
                .foregroundStyle(BroadcastTheme.subtleText)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)

            if showsBar {
                BroadcastNeonProgressBar(
                    tint: BroadcastConnectionLoadingIndicator.tint(
                        streamState: streamState,
                        statusMessage: message,
                        isReconnecting: isReconnecting
                    )
                )
            }
        }
    }
}
