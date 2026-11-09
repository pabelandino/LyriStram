import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Studio tab — emission, program audio, and the address Android cameras dial.
struct DirectorSettingsStudioTab: View {
    let viewModel: DirectorSessionViewModel

    private var liveVideoAvailable: Bool {
        LiveProgramAirStore.shared.fullScreenIsLive
            && LiveProgramAirStore.shared.fullScreenResource?.kind == .video
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 18) {
                DirectorSettingsEmissionSection(viewModel: viewModel)

                DirectorInspectorSection("Audio", systemImage: "waveform") {
                    DirectorProgramAudioSettingsView(
                        viewModel: viewModel,
                        liveVideoAvailable: liveVideoAvailable,
                        monitor: ProgramAudioMonitor.shared
                    )
                }

                DirectorConnectAddressCard(
                    addresses: viewModel.localIPv4Addresses,
                    port: viewModel.listeningPort,
                    activeHost: viewModel.advertisedConnectHost,
                    onApply: { viewModel.applyAdvertisedConnectHost($0) }
                )
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
