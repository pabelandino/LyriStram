import SwiftUI
import WebRTC
import EasyStreamCore
import EasyStreamUIComponents

/// Switcher column isolated from sidebar tab changes so WebRTC video keeps rendering smoothly.
struct DirectorSwitcherColumnView: View {
    let viewModel: DirectorSessionViewModel
    let mediaViewModel: BroadcastMediaViewModel
    @Bindable var liveProgramAir: LiveProgramAirStore

    var body: some View {
        VStack(spacing: 0) {
            DirectorStatusBar(
                connectedCameras: viewModel.connectedSourceCount,
                activeStreamingCameras: viewModel.activeStreamingSourceCount,
                programName: programDisplayName,
                programPresetLabel: viewModel.monitorQuality.progPreset.streamSpec.displayLabel,
                programTrackId: viewModel.programVideoTrack?.trackId,
                isLive: viewModel.connectedSourceCount > 0,
                encoderStats: viewModel.encoderStats,
                audioEncoderStats: viewModel.audioEncoderStats
            )

            DirectorMainSwitcherAreaView(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                liveProgramAir: liveProgramAir
            )
            .layoutPriority(1)

            DirectorTakeBarView(
                viewModel: viewModel,
                canTake: canTake
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BroadcastTheme.panelBackground)
    }

    private var programDisplayName: String? {
        guard let id = viewModel.programSourceID else { return nil }
        return viewModel.sources.first { $0.id == id }?.displayName
    }

    private var canTake: Bool {
        guard let preview = viewModel.previewSourceID else { return false }
        if let program = viewModel.programSourceID, preview == program { return false }
        return viewModel.connectionState(for: preview) == .connected
    }
}
