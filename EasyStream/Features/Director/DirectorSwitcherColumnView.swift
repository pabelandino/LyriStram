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
            previewHeader

            DirectorMainSwitcherAreaView(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                liveProgramAir: liveProgramAir
            )
            .frame(minHeight: 0, maxHeight: .infinity)
            .layoutPriority(1)
            .clipped()

            statusBar

            DirectorTakeBarView(
                viewModel: viewModel,
                canTake: canTake
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BroadcastTheme.panelBackground)
    }

    private var previewHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: "rectangle.on.rectangle")
                .font(.subheadline)
                .foregroundStyle(BroadcastTheme.previewGreen)
            Text(BroadcastTerminology.previewName)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            Spacer(minLength: 4)
        }
        .padding(.horizontal, DirectorColumnHeaderMetrics.horizontalPadding)
        .frame(height: DirectorColumnHeaderMetrics.height)
        .frame(maxWidth: .infinity)
        .background(BroadcastTheme.panelElevated)
    }

    private var statusBar: some View {
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
