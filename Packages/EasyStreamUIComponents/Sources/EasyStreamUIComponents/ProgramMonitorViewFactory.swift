import SwiftUI
import EasyStreamCore
import WebRTC

/// Presentation factory — selects the program monitor backend without leaking Metal/WebRTC into callers.
@MainActor
public enum ProgramMonitorViewFactory {
    public static var configuration = ProgramRenderConfiguration.production

    @ViewBuilder
    public static func programVideoSurface(
        programTrack: RTCVideoTrack?,
        outgoingTrack: RTCVideoTrack?,
        incomingTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        progress: Double,
        kind: SwitchTransitionKind
    ) -> some View {
        switch configuration.backend {
        case .metalCompositor:
            ProgramMetalVideoView(
                programTrack: programTrack,
                outgoingTrack: outgoingTrack,
                incomingTrack: incomingTrack,
                isTransitioning: isTransitioning,
                progress: progress,
                kind: kind
            )
        case .legacyDualWebRTC:
            ProgramCrossfadeVideoView(
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
