import SwiftUI
import EasyStreamCore
import WebRTC

/// Video layer isolated from widget/preview overlays so UI churn does not detach WebRTC renderers.
public struct StableProgramVideoView: View {
    let programDisplayTrack: RTCVideoTrack?
    let outgoingProgramTrack: RTCVideoTrack?
    let incomingProgramTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let transitionProgress: Double
    let transitionKind: SwitchTransitionKind
    let emptyStatusMessage: String
    let showsEmptyWhenNoGraphics: Bool
    let hasAirGraphics: Bool

    public init(
        programDisplayTrack: RTCVideoTrack?,
        outgoingProgramTrack: RTCVideoTrack?,
        incomingProgramTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        transitionProgress: Double,
        transitionKind: SwitchTransitionKind,
        emptyStatusMessage: String,
        showsEmptyWhenNoGraphics: Bool = true,
        hasAirGraphics: Bool = false
    ) {
        self.programDisplayTrack = programDisplayTrack
        self.outgoingProgramTrack = outgoingProgramTrack
        self.incomingProgramTrack = incomingProgramTrack
        self.isTransitioning = isTransitioning
        self.transitionProgress = transitionProgress
        self.transitionKind = transitionKind
        self.emptyStatusMessage = emptyStatusMessage
        self.showsEmptyWhenNoGraphics = showsEmptyWhenNoGraphics
        self.hasAirGraphics = hasAirGraphics
    }

    public var body: some View {
        ZStack {
            Color.black

            TransitionProgramView(
                programTrack: programDisplayTrack,
                outgoingTrack: isTransitioning ? outgoingProgramTrack : nil,
                previewTrack: incomingProgramTrack,
                isTransitioning: isTransitioning,
                progress: transitionProgress,
                kind: transitionKind
            )
            .id("director-program-video-bus")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .overlay(alignment: .bottomTrailing) {
                ProgramBusLiveResolutionBadge()
                    .padding(10)
            }

            if programDisplayTrack == nil,
               incomingProgramTrack == nil,
               showsEmptyWhenNoGraphics,
               !hasAirGraphics {
                ContentUnavailableView {
                    Label("Sin programa", systemImage: "tv.slash")
                } description: {
                    Text(emptyStatusMessage)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}
