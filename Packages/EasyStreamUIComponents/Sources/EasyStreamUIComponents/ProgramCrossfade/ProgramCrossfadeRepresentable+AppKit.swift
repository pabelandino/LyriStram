#if canImport(AppKit)
import SwiftUI
import EasyStreamCore
import WebRTC

struct ProgramCrossfadePlatformView: NSViewRepresentable {
    let programTrack: RTCVideoTrack?
    let outgoingTrack: RTCVideoTrack?
    let incomingTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let progress: Double
    let kind: SwitchTransitionKind

    func makeNSView(context: Context) -> ProgramCrossfadeContainerNSView {
        let view = ProgramCrossfadeContainerNSView()
        context.coordinator.container = view
        context.coordinator.sync(
            programTrack: programTrack,
            outgoingTrack: outgoingTrack,
            incomingTrack: incomingTrack,
            isTransitioning: isTransitioning,
            progress: progress,
            kind: kind
        )
        return view
    }

    func updateNSView(_ nsView: ProgramCrossfadeContainerNSView, context: Context) {
        context.coordinator.container = nsView
        context.coordinator.sync(
            programTrack: programTrack,
            outgoingTrack: outgoingTrack,
            incomingTrack: incomingTrack,
            isTransitioning: isTransitioning,
            progress: progress,
            kind: kind
        )
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: ProgramCrossfadeContainerNSView,
        context: Context
    ) -> CGSize? {
        ProgramCrossfadeLayout.boundedSize(for: proposal)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @MainActor
    final class Coordinator {
        weak var container: ProgramCrossfadeContainerNSView?
        private let session = ProgramCrossfadeSession()

        func sync(
            programTrack: RTCVideoTrack?,
            outgoingTrack: RTCVideoTrack?,
            incomingTrack: RTCVideoTrack?,
            isTransitioning: Bool,
            progress: Double,
            kind: SwitchTransitionKind
        ) {
            guard let container else { return }
            session.apply(
                on: container,
                programTrack: programTrack,
                outgoingTrack: outgoingTrack,
                incomingTrack: incomingTrack,
                isTransitioning: isTransitioning,
                progress: progress,
                kind: kind
            )
        }
    }
}
#endif
