import SwiftUI
import EasyStreamCore
import WebRTC

/// Full program feed for external outputs: stable video + committed air graphics only.
public struct LiveProgramFeedView: View {
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
    let emptyStatusMessage: String
    let isCleanBroadcastOutput: Bool
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
        emptyStatusMessage: String,
        isCleanBroadcastOutput: Bool = false,
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
        self.emptyStatusMessage = emptyStatusMessage
        self.isCleanBroadcastOutput = isCleanBroadcastOutput
        self.onWidgetLiveAutoDismiss = onWidgetLiveAutoDismiss
    }

    public var body: some View {
        ZStack {
            Color.black

            StableProgramVideoView(
                programDisplayTrack: programDisplayTrack,
                outgoingProgramTrack: outgoingProgramTrack,
                incomingProgramTrack: incomingProgramTrack,
                isTransitioning: isTransitioning,
                transitionProgress: transitionProgress,
                transitionKind: transitionKind,
                emptyStatusMessage: emptyStatusMessage,
                showsEmptyWhenNoGraphics: !isCleanBroadcastOutput,
                hasAirGraphics: !widgetLayers.isEmpty || fullScreenResource != nil
            )

            if let fullScreen = fullScreenResource, let fileURL = fullScreenFileURL {
                BroadcastResourceDisplayView(
                    resource: fullScreen,
                    fileURL: fileURL,
                    widgetConfiguration: nil,
                    logoURL: nil,
                    isLive: fullScreenIsLive,
                    isEditingWidget: false,
                    widgetPlacement: .constant(BroadcastWidgetPlacement())
                )
            }

            StableWidgetOverlayView(
                layers: widgetLayers,
                onWidgetLiveAutoDismiss: onWidgetLiveAutoDismiss
            )
        }
    }
}
