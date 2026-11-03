import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorTakeBarView: View {
    @Bindable var viewModel: DirectorSessionViewModel
    let canTake: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                TakeToProgramButton(isEnabled: canTake && !viewModel.isTransitioning) {
                    viewModel.takeToProgram()
                }

                Button {
                    viewModel.leaveAir()
                } label: {
                    Label(BroadcastTerminology.leaveAirAction, systemImage: "stop.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .tint(BroadcastTheme.programRed)
                .disabled(viewModel.programSourceID == nil)
                .accessibilityHint(BroadcastTerminology.leaveAirDescription)
            }
            .padding(.horizontal, 16)

            Text(BroadcastTerminology.takeDescription + " · El audio de programa permanece en su fuente asignada")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .background(.bar)
    }
}
