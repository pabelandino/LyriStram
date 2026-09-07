import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Program monitor chrome + live feed — no dependency on widget draft state.
struct DirectorProgramOutputCorePanel: View {
    let viewModel: DirectorSessionViewModel
    @Bindable var liveProgramAir: LiveProgramAirStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BroadcastTerminology.programName.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            BroadcastFixedAspectContainer {
                DirectorProgramLiveMonitorView(
                    viewModel: viewModel,
                    liveProgramAir: liveProgramAir
                )
            }
            .animation(nil, value: viewModel.isTransitioning)
            .animation(nil, value: viewModel.transitionProgress)
            .animation(nil, value: viewModel.programSourceID)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.red, lineWidth: 3)
            }
            .overlay(alignment: .topLeading) {
                if let name = programDisplayName {
                    Text("\(BroadcastTerminology.programShort) · \(name)")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.red, in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(.white)
                        .padding(12)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var programDisplayName: String? {
        guard let id = viewModel.programSourceID else { return nil }
        return viewModel.sources.first { $0.id == id }?.displayName
    }
}
