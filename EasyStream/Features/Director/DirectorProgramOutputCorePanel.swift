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

            BroadcastAspectRatioLayout {
                DirectorProgramLiveMonitorView(
                    viewModel: viewModel,
                    liveProgramAir: liveProgramAir
                )
            }
            .frame(maxWidth: .infinity)
            .animation(nil, value: viewModel.isTransitioning)
            .animation(nil, value: viewModel.transitionProgress)
            .animation(nil, value: viewModel.programSourceID)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(viewModel.programSourceID == nil ? Color.clear : Color.red, lineWidth: 3)
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
            .overlay(alignment: .topTrailing) {
                if viewModel.programSourceID != nil {
                    Button {
                        viewModel.leaveAir()
                    } label: {
                        Label(BroadcastTerminology.leaveAirAction, systemImage: "stop.circle.fill")
                            .font(.caption.weight(.bold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(BroadcastTheme.programRed)
                    .padding(12)
                    .accessibilityHint(BroadcastTerminology.leaveAirDescription)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var programDisplayName: String? {
        guard let id = viewModel.programSourceID else { return nil }
        return viewModel.sources.first { $0.id == id }?.displayName
    }
}
