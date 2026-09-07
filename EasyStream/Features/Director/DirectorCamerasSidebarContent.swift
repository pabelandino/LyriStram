import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorCamerasSidebarContent: View {
    let viewModel: DirectorSessionViewModel

    var body: some View {
        BroadcastSectionHeader("Cámaras", systemImage: "video")

        if viewModel.sources.isEmpty {
            Text("Esperando cámaras…")
                .font(.subheadline)
                .foregroundStyle(BroadcastTheme.subtleText)
                .padding(.horizontal, 8)
        } else {
            ForEach(viewModel.sources) { source in
                DirectorSourceListRow(
                    name: source.displayName,
                    isPreview: source.id == viewModel.previewSourceID,
                    isProgram: source.id == viewModel.programSourceID,
                    isAudio: source.id == viewModel.programAudioSourceID,
                    isConnected: source.connectionState == .connected,
                    isSelected: source.id == viewModel.previewSourceID,
                    onSelect: { viewModel.selectPreview(source.id) },
                    onReconnect: source.connectionState != .connected
                        ? { viewModel.reconnectCamera(source.id) }
                        : nil
                )
            }
        }

        if !viewModel.devices.isEmpty {
            BroadcastSectionHeader("En red", systemImage: "wifi")
                .padding(.top, 8)
            ForEach(viewModel.devices) { device in
                DiscoveredDeviceRow(device: device)
                    .padding(.horizontal, 4)
            }
        }
    }
}
