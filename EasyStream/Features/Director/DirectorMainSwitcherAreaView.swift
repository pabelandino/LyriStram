import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Program monitor + preview grid.
struct DirectorMainSwitcherAreaView: View {
    let viewModel: DirectorSessionViewModel
    let mediaViewModel: BroadcastMediaViewModel
    @Bindable var liveProgramAir: LiveProgramAirStore

    var body: some View {
        VStack(spacing: 16) {
            DirectorPreviewGridView(viewModel: viewModel)
                .frame(height: DirectorPreviewGridMetrics.bandHeight)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            DirectorProgramOutputCorePanel(
                viewModel: viewModel,
                liveProgramAir: liveProgramAir
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.92))
        .clipped()
        .animation(nil, value: viewModel.previewSourceID)
        .animation(nil, value: viewModel.programSourceID)
#if os(macOS)
        .focusable()
        .focusEffectDisabled(mediaViewModel.isWidgetPlacementEditing)
        .onKeyPress(.space) {
            guard !mediaViewModel.isWidgetPlacementEditing else { return .ignored }
            guard canTake, !viewModel.isTransitioning else { return .ignored }
            viewModel.takeToProgram()
            return .handled
        }
#endif
    }

    private var canTake: Bool {
        guard let preview = viewModel.previewSourceID else { return false }
        if let program = viewModel.programSourceID, preview == program { return false }
        return viewModel.connectionState(for: preview) == .connected
    }
}
