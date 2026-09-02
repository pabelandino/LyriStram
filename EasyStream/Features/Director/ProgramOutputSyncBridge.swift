import SwiftUI
import EasyStreamCore

/// Keeps the external program window video bus in sync without coupling to widget draft edits.
struct ProgramOutputSyncBridge: View {
    let viewModel: DirectorSessionViewModel

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .task(id: stableVideoToken) {
                syncVideoBus()
            }
            .task(id: viewModel.isTransitioning) {
                guard viewModel.isTransitioning else { return }
                while !Task.isCancelled, viewModel.isTransitioning {
                    syncVideoBus()
                    try? await Task.sleep(for: .milliseconds(16))
                }
                syncVideoBus()
            }
    }

    /// Source/transition kind only — progress is polled during transitions to avoid task churn every frame.
    private var stableVideoToken: String {
        [
            viewModel.programSourceID?.rawValue.uuidString ?? "none",
            viewModel.previewSourceID?.rawValue.uuidString ?? "none",
            String(viewModel.isTransitioning),
            viewModel.selectedTransition.kind.rawValue
        ].joined(separator: "|")
    }

    private func syncVideoBus() {
        DirectorProgramOutputStore.shared.syncVideoBus(
            programDisplayTrack: viewModel.programDisplayTrack,
            outgoingProgramTrack: viewModel.outgoingProgramVideoTrack,
            incomingProgramTrack: viewModel.isTransitioning
                ? viewModel.transitionIncomingVideoTrack
                : nil,
            isTransitioning: viewModel.isTransitioning,
            transitionProgress: viewModel.transitionProgress,
            transitionKind: viewModel.selectedTransition.kind,
            programSourceName: viewModel.sources.first { $0.id == viewModel.programSourceID }?.displayName,
            emptyStatusMessage: viewModel.statusMessage
        )
    }
}
