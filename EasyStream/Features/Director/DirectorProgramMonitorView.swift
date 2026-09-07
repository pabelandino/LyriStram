import SwiftUI
import EasyStreamUIComponents

/// Live program monitor — switcher/video + committed air bus only (never draft/widget studio state).
struct DirectorProgramLiveMonitorView: View {
    let viewModel: DirectorSessionViewModel
    @Bindable var liveProgramAir: LiveProgramAirStore

    var body: some View {
        ZStack {
            DirectorProgramVideoBusView(
                viewModel: viewModel,
                hasAirGraphics: !liveProgramAir.widgetLayers.isEmpty || liveProgramAir.fullScreenResource != nil
            )
            .equatable()

            DirectorProgramAirGraphicsView(
                widgetLayers: liveProgramAir.widgetLayers,
                fullScreenResource: liveProgramAir.fullScreenResource,
                fullScreenFileURL: liveProgramAir.fullScreenFileURL,
                fullScreenIsLive: liveProgramAir.fullScreenIsLive,
                onWidgetLiveAutoDismiss: { liveProgramAir.requestWidgetAutoDismiss($0) }
            )
        }
        .animation(nil, value: viewModel.isTransitioning)
        .animation(nil, value: viewModel.transitionProgress)
        .animation(nil, value: liveProgramAir.revision)
    }
}
