#if os(iOS) || os(macOS)
import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

struct CameraSessionIntercomCard: View {
    @Bindable var intercomService: TeamIntercomService

    var body: some View {
        TeamIntercomPanel(
            peers: intercomService.peers,
            statusMessage: intercomService.statusMessage,
            isEnabled: intercomService.isEnabled,
            isTalking: intercomService.isTalking,
            isActivating: intercomService.isActivating,
            targetPeerID: intercomService.targetPeerID,
            needsLocalNetworkPermission: intercomService.needsLocalNetworkPermission,
            onOpenSettings: PlatformSettings.openAppSettings,
            onTargetPeerChange: { intercomService.setTargetPeer($0) },
            onEnabledChange: { intercomService.isEnabled = $0 },
            onTalkBegin: { intercomService.toggleTalking() },
            onTalkEnd: { intercomService.toggleTalking() }
        )
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .broadcastPanel(elevated: true)
    }
}
#endif
