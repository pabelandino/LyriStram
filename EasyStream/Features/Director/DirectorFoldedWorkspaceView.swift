import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Half-folded inner display. Preview and program sit above the crease; cameras and the rail sit below it.
struct DirectorFoldedWorkspaceView: View {
    let viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var intercomService: TeamIntercomService
    @Bindable var liveProgramAir: LiveProgramAirStore
    let topHeight: CGFloat
    let foldHeight: CGFloat
    let onLeaveRole: () -> Void
    let onCreateWidget: () -> Void
    let onOpenSettings: () -> Void
    let onOpenMonitor: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 10) {
                    DirectorPreviewGridView(viewModel: viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                    DirectorProgramOutputCorePanel(
                        viewModel: viewModel,
                        liveProgramAir: liveProgramAir
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .frame(maxHeight: .infinity)

                DirectorTakeBarView(viewModel: viewModel, canTake: canTake)
            }
            .frame(height: topHeight)
            .padding(.horizontal, 8)

            Color.clear
                .frame(height: foldHeight)
                .accessibilityHidden(true)

            HStack(spacing: 0) {
                DirectorSourceSidebarView(
                    viewModel: viewModel,
                    onBack: onLeaveRole,
                    onOpenSettings: onOpenSettings,
                    onOpenMonitor: onOpenMonitor
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                DirectorLibraryRailView(
                    viewModel: viewModel,
                    mediaViewModel: mediaViewModel,
                    intercomService: intercomService,
                    onCreateWidget: onCreateWidget
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(BroadcastTheme.panelBackground)
    }

    private var canTake: Bool {
        guard let preview = viewModel.previewSourceID else { return false }
        if let program = viewModel.programSourceID, preview == program { return false }
        return viewModel.connectionState(for: preview) == .connected
    }
}
