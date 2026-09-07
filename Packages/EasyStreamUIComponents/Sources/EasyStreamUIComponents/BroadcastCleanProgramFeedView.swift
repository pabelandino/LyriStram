import SwiftUI
import EasyStreamCore
import WebRTC

/// Edge-to-edge clean output for external displays and network-bound program (no UI chrome).
public struct BroadcastCleanProgramFeedView: View {
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
        widgetLayers: [ProgramFeedWidgetLayer],
        fullScreenResource: BroadcastResource?,
        fullScreenFileURL: URL?,
        fullScreenIsLive: Bool,
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
        GeometryReader { geometry in
            LiveProgramFeedView(
                programDisplayTrack: programDisplayTrack,
                outgoingProgramTrack: outgoingProgramTrack,
                incomingProgramTrack: incomingProgramTrack,
                isTransitioning: isTransitioning,
                transitionProgress: transitionProgress,
                transitionKind: transitionKind,
                widgetLayers: widgetLayers,
                fullScreenResource: fullScreenResource,
                fullScreenFileURL: fullScreenFileURL,
                fullScreenIsLive: fullScreenIsLive,
                emptyStatusMessage: "",
                isCleanBroadcastOutput: true,
                onWidgetLiveAutoDismiss: onWidgetLiveAutoDismiss
            )
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}
