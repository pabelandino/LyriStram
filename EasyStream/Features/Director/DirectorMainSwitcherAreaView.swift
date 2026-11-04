import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Program monitor + preview grid.
struct DirectorMainSwitcherAreaView: View {
    let viewModel: DirectorSessionViewModel
    let mediaViewModel: BroadcastMediaViewModel
    @Bindable var liveProgramAir: LiveProgramAirStore
    var body: some View {
        VStack(spacing: 12) {
            DirectorPreviewGridView(viewModel: viewModel, showsTitle: false)
                .frame(height: DirectorPreviewGridMetrics.tileHeight + 4)
                .fixedSize(horizontal: false, vertical: true)

            DirectorProgramOutputCorePanel(
                viewModel: viewModel,
                liveProgramAir: liveProgramAir
            )
            .layoutPriority(1)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BroadcastTheme.panelBackground)
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
