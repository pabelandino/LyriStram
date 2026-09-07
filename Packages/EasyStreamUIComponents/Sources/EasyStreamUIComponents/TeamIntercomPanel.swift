import SwiftUI
import EasyStreamCore

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
