import SwiftUI
import EasyStreamCore
import WebRTC

/// Persistent dual-slot WebRTC renderer for program transitions — avoids SwiftUI remount flashes.
public struct ProgramCrossfadeVideoView: View {
    let programTrack: RTCVideoTrack?
    let outgoingTrack: RTCVideoTrack?
    let incomingTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let progress: Double
    let kind: SwitchTransitionKind

    public init(
        programTrack: RTCVideoTrack?,
        outgoingTrack: RTCVideoTrack?,
        incomingTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        progress: Double,
        kind: SwitchTransitionKind
    ) {
        self.programTrack = programTrack
        self.outgoingTrack = outgoingTrack
        self.incomingTrack = incomingTrack
        self.isTransitioning = isTransitioning
        self.progress = progress
        self.kind = kind
    }

    public var body: some View {
        ProgramCrossfadePlatformView(
            programTrack: programTrack,
            outgoingTrack: outgoingTrack,
            incomingTrack: incomingTrack,
            isTransitioning: isTransitioning,
            progress: progress,
            kind: kind
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}
