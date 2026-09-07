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
            // Single persistent MTKView + frame bus: WebRTC decodes on worker threads,
            // Metal compositor displays — cuts swap textures, never SwiftUI/NSView trees.
            if programTrack != nil || incomingTrack != nil || isTransitioning {
                ProgramMetalVideoView(
                    programTrack: programTrack,
                    outgoingTrack: outgoingTrack,
                    incomingTrack: incomingTrack,
                    isTransitioning: isTransitioning,
                    progress: progress,
                    kind: kind
                )
            } else {
                Color.black
            }
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
