import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorTakeBarView: View {
    @Bindable var viewModel: DirectorSessionViewModel
    let canTake: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                TakeToProgramButton(isEnabled: canTake && !viewModel.isTransitioning) {
                    viewModel.takeToProgram()
                }
                .frame(maxWidth: .infinity, minHeight: 32, maxHeight: 32)

                Button {
                    viewModel.leaveAir()
                } label: {
                    Label(BroadcastTerminology.leaveAirAction, systemImage: "stop.circle.fill")
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, minHeight: 32, maxHeight: 32)
                        .foregroundStyle(BroadcastTheme.programRed.opacity(viewModel.programSourceID == nil ? 0.45 : 1))
                        .background {
                            RoundedRectangle(cornerRadius: BroadcastGlassStyles.buttonCornerRadius, style: .continuous)
                                .strokeBorder(BroadcastTheme.programRed.opacity(viewModel.programSourceID == nil ? 0.35 : 0.9), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.programSourceID == nil)
                .accessibilityHint(BroadcastTerminology.leaveAirDescription)
            }
            .padding(.horizontal, 16)

            Text(BroadcastTerminology.takeDescription + " · El audio de programa permanece en su fuente asignada")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.bottom, 4)
        }
        .padding(.top, 6)
        .background(.bar)
    }
}
