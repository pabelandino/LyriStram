import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Fully open director: cameras, switcher, and the library rail.
struct DirectorColumnWorkspaceView: View {
    let viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var intercomService: TeamIntercomService
    @Bindable var liveProgramAir: LiveProgramAirStore
    let canvasWidth: CGFloat
    let onLeaveRole: () -> Void
    let onCreateWidget: () -> Void
    let onOpenSettings: () -> Void
    let onOpenMonitor: () -> Void

    var body: some View {
        let compact = canvasWidth < 1400
        let sidebarWidth: CGFloat = compact ? 214 : 260
        let railWidth: CGFloat = compact ? 248 : 272
        HStack(alignment: .top, spacing: 0) {
            DirectorSourceSidebarView(
                viewModel: viewModel,
                onBack: onLeaveRole,
                onOpenSettings: onOpenSettings,
                onOpenMonitor: onOpenMonitor
            )
            .frame(width: sidebarWidth)
            .frame(maxHeight: .infinity, alignment: .top)

            DirectorSwitcherColumnView(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                liveProgramAir: liveProgramAir
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .layoutPriority(1)

            DirectorLibraryRailView(
                viewModel: viewModel,
                mediaViewModel: mediaViewModel,
                intercomService: intercomService,
                onCreateWidget: onCreateWidget
            )
            .frame(width: railWidth)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BroadcastTheme.panelBackground)
    }
}
