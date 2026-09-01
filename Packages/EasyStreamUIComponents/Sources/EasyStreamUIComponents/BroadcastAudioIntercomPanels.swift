import SwiftUI
import EasyStreamCore

public struct ProgramAudioSourcePanel: View {
    public struct SourceOption: Identifiable, Equatable {
        public let id: CameraSourceID
        public let name: String
        public let isConnected: Bool

        public init(id: CameraSourceID, name: String, isConnected: Bool) {
            self.id = id
            self.name = name
            self.isConnected = isConnected
        }
    }

    let sources: [SourceOption]
    let programAudioSourceID: CameraSourceID?
    let onSelect: (CameraSourceID) -> Void

    public init(
        sources: [SourceOption],
        programAudioSourceID: CameraSourceID?,
        onSelect: @escaping (CameraSourceID) -> Void
    ) {
        self.sources = sources
        self.programAudioSourceID = programAudioSourceID
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("El audio de programa se toma de la cámara seleccionada. El video puede estar en otra fuente.")
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)

            if sources.isEmpty {
                BroadcastInspectorEmptyState("Sin fuentes de audio", systemImage: "mic.slash")
            } else {
                ForEach(sources) { source in
                    Button {
                        onSelect(source.id)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: source.id == programAudioSourceID ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(source.id == programAudioSourceID ? BroadcastTheme.audioGold : BroadcastTheme.subtleText)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(source.name)
                                    .font(.subheadline.weight(.medium))
                                Text(source.isConnected ? "Conectada" : "Desconectada")
                                    .font(.caption2)
                                    .foregroundStyle(BroadcastTheme.subtleText)
                            }

                            Spacer()

                            if source.id == programAudioSourceID {
                                BroadcastTallyPill(BroadcastTerminology.audioShort, color: BroadcastTheme.audioGold)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            source.id == programAudioSourceID
                                ? BroadcastTheme.audioGold.opacity(0.12)
                                : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

public struct TeamIntercomPanel: View {
    let peers: [TeamIntercomPeer]
    let statusMessage: String
    let isEnabled: Bool
    let isTalking: Bool
    let isActivating: Bool
    let targetPeerID: UUID?
    let needsLocalNetworkPermission: Bool
    let onOpenSettings: (() -> Void)?
    let onTargetPeerChange: (UUID) -> Void
    let onEnabledChange: (Bool) -> Void
    let onTalkBegin: () -> Void
    let onTalkEnd: () -> Void

    public init(
        peers: [TeamIntercomPeer],
        statusMessage: String,
        isEnabled: Bool,
        isTalking: Bool,
        isActivating: Bool = false,
        targetPeerID: UUID? = nil,
        needsLocalNetworkPermission: Bool = false,
        onOpenSettings: (() -> Void)? = nil,
        onTargetPeerChange: @escaping (UUID) -> Void = { _ in },
        onEnabledChange: @escaping (Bool) -> Void,
        onTalkBegin: @escaping () -> Void,
        onTalkEnd: @escaping () -> Void
    ) {
        self.peers = peers
        self.statusMessage = statusMessage
        self.isEnabled = isEnabled
        self.isTalking = isTalking
        self.isActivating = isActivating
        self.targetPeerID = targetPeerID
        self.needsLocalNetworkPermission = needsLocalNetworkPermission
        self.onOpenSettings = onOpenSettings
        self.onTargetPeerChange = onTargetPeerChange
        self.onEnabledChange = onEnabledChange
        self.onTalkBegin = onTalkBegin
        self.onTalkEnd = onTalkEnd
    }

    private var activeTargetName: String? {
        if let targetPeerID, let peer = peers.first(where: { $0.id == targetPeerID }) {
            return peer.displayName
        }
        if peers.count == 1 {
            return peers.first?.displayName
        }
        return nil
    }

    private var canTalk: Bool {
        isEnabled && activeTargetName != nil
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if needsLocalNetworkPermission, let onOpenSettings {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Red local requerida", systemImage: "wifi.exclamationmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BroadcastTheme.liveAmber)
                    Text(EasyStreamNetworkMessages.localNetworkPermissionRequired)
                        .font(.caption)
                        .foregroundStyle(BroadcastTheme.subtleText)
                    Button("Abrir Ajustes", action: onOpenSettings)
                        .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
                }
                .padding(10)
                .background(BroadcastTheme.liveAmber.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }

            Toggle("Intercom activo", isOn: Binding(
                get: { isEnabled },
                set: onEnabledChange
            ))
            .toggleStyle(.switch)

            Text("Independiente del audio de programa. Silenciar micrófono no bloquea el intercom.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)

            Text(statusMessage)
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)

            if !peers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(peers.count > 1 ? "Destinatario" : "En canal")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BroadcastTheme.subtleText)

                    if peers.count > 1 {
                        ForEach(peers) { peer in
                            Button {
                                onTargetPeerChange(peer.id)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: peer.id == targetPeerID ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(peer.id == targetPeerID ? BroadcastTheme.programRed : BroadcastTheme.subtleText)
                                    Label(peer.displayName, systemImage: "person.wave.2")
                                        .font(.subheadline)
                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    peer.id == targetPeerID
                                        ? BroadcastTheme.programRed.opacity(0.12)
                                        : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 8)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    } else if let peer = peers.first {
                        Label(peer.displayName, systemImage: "person.wave.2")
                            .font(.subheadline)
                    }
                }
            }

            IntercomPushToTalkButton(
                isEnabled: canTalk,
                isTalking: isTalking,
                isActivating: isActivating,
                targetDisplayName: activeTargetName,
                onToggle: {
                    if isTalking || isActivating {
                        onTalkEnd()
                    } else {
                        onTalkBegin()
                    }
                }
            )
        }
    }
}

public struct IntercomPushToTalkButton: View {
    let isEnabled: Bool
    let isTalking: Bool
    let isActivating: Bool
    let targetDisplayName: String?
    let onToggle: () -> Void

    private var isLive: Bool { isTalking && !isActivating }

    public init(
        isEnabled: Bool,
        isTalking: Bool,
        isActivating: Bool = false,
        targetDisplayName: String? = nil,
        onToggle: @escaping () -> Void
    ) {
        self.isEnabled = isEnabled
        self.isTalking = isTalking
        self.isActivating = isActivating
        self.targetDisplayName = targetDisplayName
        self.onToggle = onToggle
    }

    public var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                micIcon

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                    Text(subtitle)
                        .font(.caption2.weight(.medium))
                        .opacity(0.88)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, isLive ? 16 : 14)
            .frame(maxWidth: .infinity)
            .background { buttonBackground }
            .foregroundStyle(.white)
            .clipShape(buttonShape)
            .overlay {
                if isActivating {
                    IntercomActivationRing(cornerRadius: idleCornerRadius)
                } else if isLive {
                    IntercomPushToTalkPulseRings(cornerRadius: activeCornerRadius)
                }
            }
            .overlay {
                buttonShape
                    .strokeBorder(
                        ringColor.opacity(isActivating || isLive ? 0.55 : 0.12),
                        lineWidth: isActivating ? 2.5 : 1
                    )
            }
            .shadow(
                color: ringColor.opacity(isLive ? 0.55 : isActivating ? 0.45 : 0.35),
                radius: isLive ? 16 : isActivating ? 12 : 8,
                y: isLive ? 6 : 3
            )
            .scaleEffect(isLive ? 1.03 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isLive)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isActivating)
        .opacity(isEnabled ? 1 : 0.45)
    }

    private var title: String {
        if isActivating {
            return "Activando intercom…"
        }
        if isLive {
            if let targetDisplayName {
                return "Hablando con \(targetDisplayName)"
            }
            return "Intercom activo"
        }
        return "Toca para hablar"
    }

    private var subtitle: String {
        if isActivating {
            return "Preparando micrófono del intercom"
        }
        if isLive {
            return "Toca de nuevo para silenciar"
        }
        if let targetDisplayName {
            return "Intercom · \(targetDisplayName)"
        }
        return "Elige un destinatario arriba"
    }

    private var ringColor: Color {
        if isActivating {
            return BroadcastTheme.studioAccent
        }
        return isLive ? BroadcastTheme.programRed : BroadcastTheme.studioAccent
    }

    @ViewBuilder
    private var micIcon: some View {
        let icon = Image(systemName: iconName)
            .font(.title3.weight(.semibold))
        if #available(iOS 17.0, macOS 14.0, *) {
            icon.symbolEffect(.variableColor.iterative.reversing, isActive: isLive)
        } else {
            icon
        }
    }

    private var iconName: String {
        if isActivating {
            return "mic.badge.plus"
        }
        return isLive ? "waveform.circle.fill" : "mic.fill"
    }

    private var idleCornerRadius: CGFloat { 12 }
    private var activeCornerRadius: CGFloat { 22 }

    private var buttonShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: isLive ? activeCornerRadius : idleCornerRadius,
            style: .continuous
        )
    }

    @ViewBuilder
    private var buttonBackground: some View {
        if isLive {
            LinearGradient(
                colors: [
                    BroadcastTheme.programRed,
                    BroadcastTheme.liveAmber.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [
                    BroadcastTheme.studioAccent.opacity(0.95),
                    BroadcastTheme.controlAccent.opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private struct IntercomActivationRing: View {
    let cornerRadius: CGFloat

    @State private var rotation: Double = 0

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(
                AngularGradient(
                    colors: [
                        BroadcastTheme.studioAccent.opacity(0.15),
                        BroadcastTheme.studioAccent,
                        BroadcastTheme.controlAccent,
                        BroadcastTheme.studioAccent.opacity(0.15),
                    ],
                    center: .center
                ),
                lineWidth: 3
            )
            .rotationEffect(.degrees(rotation))
            .shadow(color: BroadcastTheme.studioAccent.opacity(0.55), radius: 10)
            .allowsHitTesting(false)
            .onAppear {
                rotation = 0
                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

private struct IntercomPushToTalkPulseRings: View {
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                IntercomPushToTalkPulseRing(cornerRadius: cornerRadius, delay: Double(index) * 0.28)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct IntercomPushToTalkPulseRing: View {
    let cornerRadius: CGFloat
    let delay: Double

    @State private var isPulsing = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(BroadcastTheme.programRed.opacity(0.75), lineWidth: 2.5)
            .scaleEffect(isPulsing ? 1.18 : 1)
            .opacity(isPulsing ? 0 : 0.85)
            .onAppear { startPulsing() }
    }

    private func startPulsing() {
        isPulsing = false
        withAnimation(.easeOut(duration: 1.05).repeatForever(autoreverses: false).delay(delay)) {
            isPulsing = true
        }
    }
}
