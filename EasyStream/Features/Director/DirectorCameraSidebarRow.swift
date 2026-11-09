import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorCameraSidebarRow: View {
    let viewModel: DirectorSessionViewModel
    let source: ConnectedCameraSource

    var body: some View {
        DirectorSourceListRow(
            name: source.displayName,
            platform: source.platform,
            isPreview: source.id == viewModel.previewSourceID,
            isProgram: source.id == viewModel.programSourceID,
            isAudio: source.id == viewModel.programAudioSourceID,
            isConnected: source.connectionState == .connected,
            connectionState: source.connectionState,
            signalLevel: signalLevel,
            isSelected: source.id == viewModel.previewSourceID,
            onSelect: { viewModel.selectPreview(source.id) },
            onReconnect: source.connectionState != .connected
                ? { viewModel.reconnectCamera(source.id) }
                : nil
        )
    }

    private var signalLevel: Int {
        switch source.connectionState {
        case .connected:
            return 4
        case .connecting, .signaling:
            return 2
        default:
            let onNetwork = viewModel.devices.contains { device in
                device.id == source.id.rawValue && device.isProtocolCompatible
            }
            return onNetwork ? 1 : 0
        }
    }
}
