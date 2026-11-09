import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorCamerasSidebarContent: View {
    let viewModel: DirectorSessionViewModel

    private var wifiSources: [ConnectedCameraSource] {
        viewModel.sources.filter { $0.link != .atem }
    }

    private var atemSources: [ConnectedCameraSource] {
        viewModel.sources.filter { $0.link == .atem }
    }

    var body: some View {
        if viewModel.sources.isEmpty {
            Text("Esperando cámaras…")
                .font(.subheadline)
                .foregroundStyle(BroadcastTheme.subtleText)
                .padding(.horizontal, 8)
        } else {
            ForEach(wifiSources) { source in
                DirectorCameraSidebarRow(viewModel: viewModel, source: source)
            }
            if !atemSources.isEmpty {
                DirectorATEMCamerasAccordion(viewModel: viewModel, sources: atemSources)
            }
        }
    }
}
