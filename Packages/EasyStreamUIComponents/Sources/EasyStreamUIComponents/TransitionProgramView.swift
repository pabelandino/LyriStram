import SwiftUI
import EasyStreamCore
import WebRTC

public struct TransitionProgramView: View {
    let programTrack: RTCVideoTrack?
    let outgoingTrack: RTCVideoTrack?
    let previewTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let progress: Double
    let kind: SwitchTransitionKind

    public init(
        programTrack: RTCVideoTrack?,
        outgoingTrack: RTCVideoTrack?,
        previewTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        progress: Double,
        kind: SwitchTransitionKind
    ) {
        self.programTrack = programTrack
        self.outgoingTrack = outgoingTrack
        self.previewTrack = previewTrack
        self.isTransitioning = isTransitioning
        self.progress = progress
        self.kind = kind
    }

    /// Backward-compatible entry point for simple two-track wiring.
    public init(
        outgoingTrack: RTCVideoTrack?,
        incomingTrack: RTCVideoTrack?,
        progress: Double,
        kind: SwitchTransitionKind
    ) {
        self.init(
            programTrack: incomingTrack,
            outgoingTrack: outgoingTrack,
            previewTrack: outgoingTrack == nil ? nil : incomingTrack,
            isTransitioning: outgoingTrack != nil,
            progress: progress,
            kind: kind
        )
    }

    public var body: some View {
        Group {
            if programTrack != nil || previewTrack != nil || isTransitioning {
                ProgramMonitorViewFactory.programVideoSurface(
                    programTrack: programTrack,
                    outgoingTrack: isTransitioning ? outgoingTrack : nil,
                    incomingTrack: previewTrack,
                    isTransitioning: isTransitioning,
                    progress: progress,
                    kind: kind
                )
            } else {
                Color.black
            }
        }
        .animation(nil, value: isTransitioning)
        .animation(nil, value: progress)
    }
}
