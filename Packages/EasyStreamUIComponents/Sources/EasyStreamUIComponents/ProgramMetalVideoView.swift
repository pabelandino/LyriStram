import SwiftUI
import EasyStreamCore
import WebRTC

/// Single-surface Metal program monitor — video transitions only (graphics stay in SwiftUI overlays).
public struct ProgramMetalVideoView: View {
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
        metalPlatformView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }

    @ViewBuilder
    private var metalPlatformView: some View {
        BroadcastMetalProgramFeedPlatformView(
            programTrack: programTrack,
            outgoingTrack: outgoingTrack,
            incomingTrack: incomingTrack,
            isTransitioning: isTransitioning,
            progress: progress,
            kind: kind,
            widgetLayers: [],
            fullScreenResource: nil,
            fullScreenFileURL: nil,
            fullScreenIsLive: false,
            embedsOverlays: false,
            onWidgetLiveAutoDismiss: nil
        )
    }
}
