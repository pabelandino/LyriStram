#if os(macOS)
import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorStreamSettingsWindowContent: View {
    @Bindable var viewModel: DirectorSessionViewModel
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            StreamDestinationPanel(
                destination: $viewModel.streamDestination,
                publisherStats: viewModel.publisherStats,
                isPublishing: viewModel.isPublishing,
                onStart: {
                    viewModel.startPublishing()
                    onDone()
                },
                onStop: { viewModel.stopPublishing() }
            )
            .padding()
            .navigationTitle("Destino RTMPS")
            .background(BroadcastTheme.panelBackground)
            .broadcastStudioChrome()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo", action: onDone)
                }
            }
        }
        .frame(minWidth: 420, minHeight: 280)
    }
}
#endif
