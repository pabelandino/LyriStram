import SwiftUI
import EasyStreamCore
import WebRTC

/// Single Metal compositor output: program video transitions + on-air widget overlays.
public struct BroadcastMetalProgramFeedView: View {
    let programDisplayTrack: RTCVideoTrack?
    let outgoingProgramTrack: RTCVideoTrack?
    let incomingProgramTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let transitionProgress: Double
    let transitionKind: SwitchTransitionKind
    let widgetLayers: [ProgramFeedWidgetLayer]
    let fullScreenResource: BroadcastResource?
    let fullScreenFileURL: URL?
    let fullScreenIsLive: Bool
    let onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    public init(
        programDisplayTrack: RTCVideoTrack?,
        outgoingProgramTrack: RTCVideoTrack?,
        incomingProgramTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        transitionProgress: Double,
        transitionKind: SwitchTransitionKind,
        widgetLayers: [ProgramFeedWidgetLayer] = [],
        fullScreenResource: BroadcastResource? = nil,
        fullScreenFileURL: URL? = nil,
        fullScreenIsLive: Bool = false,
        onWidgetLiveAutoDismiss: ((UUID) -> Void)? = nil
    ) {
        self.programDisplayTrack = programDisplayTrack
        self.outgoingProgramTrack = outgoingProgramTrack
        self.incomingProgramTrack = incomingProgramTrack
        self.isTransitioning = isTransitioning
        self.transitionProgress = transitionProgress
        self.transitionKind = transitionKind
        self.widgetLayers = widgetLayers
        self.fullScreenResource = fullScreenResource
        self.fullScreenFileURL = fullScreenFileURL
        self.fullScreenIsLive = fullScreenIsLive
        self.onWidgetLiveAutoDismiss = onWidgetLiveAutoDismiss
    }

    public var body: some View {
        BroadcastMetalProgramFeedPlatformView(
            programTrack: programDisplayTrack,
            outgoingTrack: isTransitioning ? outgoingProgramTrack : nil,
            incomingTrack: incomingProgramTrack,
            isTransitioning: isTransitioning,
            progress: transitionProgress,
            kind: transitionKind,
            widgetLayers: widgetLayers,
            fullScreenResource: fullScreenResource,
            fullScreenFileURL: fullScreenFileURL,
            fullScreenIsLive: fullScreenIsLive,
            embedsOverlays: true,
            onWidgetLiveAutoDismiss: onWidgetLiveAutoDismiss
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}
