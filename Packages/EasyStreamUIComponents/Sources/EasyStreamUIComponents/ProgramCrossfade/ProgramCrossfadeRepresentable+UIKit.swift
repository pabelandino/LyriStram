#if canImport(UIKit)
import SwiftUI
import EasyStreamCore
import WebRTC

struct ProgramCrossfadePlatformView: UIViewRepresentable {
    let programTrack: RTCVideoTrack?
    let outgoingTrack: RTCVideoTrack?
    let incomingTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let progress: Double
    let kind: SwitchTransitionKind

    func makeUIView(context: Context) -> ProgramCrossfadeContainerUIView {
        let view = ProgramCrossfadeContainerUIView()
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

    func updateUIView(_ uiView: ProgramCrossfadeContainerUIView, context: Context) {
        context.coordinator.container = uiView
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
        uiView: ProgramCrossfadeContainerUIView,
        context: Context
    ) -> CGSize? {
        ProgramCrossfadeLayout.boundedSize(for: proposal)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @MainActor
    final class Coordinator {
        weak var container: ProgramCrossfadeContainerUIView?
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
