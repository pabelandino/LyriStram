import SwiftUI
import WebRTC
import EasyStreamCore
import EasyStreamUIComponents

/// Reads only switcher/video state — not widget draft configuration.
struct DirectorProgramVideoBusView: View, Equatable {
    let programDisplayTrack: RTCVideoTrack?
    let outgoingProgramTrack: RTCVideoTrack?
    let incomingProgramTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let transitionProgress: Double
    let transitionKind: SwitchTransitionKind
    let emptyStatusMessage: String
    let hasAirGraphics: Bool

    init(viewModel: DirectorSessionViewModel, hasAirGraphics: Bool) {
        programDisplayTrack = viewModel.programDisplayTrack
        outgoingProgramTrack = viewModel.outgoingProgramVideoTrack
        incomingProgramTrack = viewModel.programBusIncomingTrack
        isTransitioning = viewModel.isTransitioning
        transitionProgress = viewModel.transitionProgress
        transitionKind = viewModel.selectedTransition.kind
        emptyStatusMessage = viewModel.statusMessage
        self.hasAirGraphics = hasAirGraphics
    }

    nonisolated static func == (lhs: DirectorProgramVideoBusView, rhs: DirectorProgramVideoBusView) -> Bool {
        guard lhs.programDisplayTrack === rhs.programDisplayTrack
            && lhs.outgoingProgramTrack === rhs.outgoingProgramTrack
            && lhs.incomingProgramTrack === rhs.incomingProgramTrack
            && lhs.isTransitioning == rhs.isTransitioning
            && lhs.transitionKind == rhs.transitionKind
            && lhs.emptyStatusMessage == rhs.emptyStatusMessage
            && lhs.hasAirGraphics == rhs.hasAirGraphics
        else { return false }

        if lhs.isTransitioning && rhs.isTransitioning {
            if lhs.transitionProgress >= 0.95 || rhs.transitionProgress >= 0.95 {
                return lhs.transitionProgress == rhs.transitionProgress
            }
            return abs(lhs.transitionProgress - rhs.transitionProgress) < 0.02
        }
        return true
    }

    var body: some View {
        StableProgramVideoView(
            programDisplayTrack: programDisplayTrack,
            outgoingProgramTrack: outgoingProgramTrack,
            incomingProgramTrack: incomingProgramTrack,
            isTransitioning: isTransitioning,
            transitionProgress: transitionProgress,
            transitionKind: transitionKind,
            emptyStatusMessage: emptyStatusMessage,
            hasAirGraphics: hasAirGraphics
        )
    }
}
