import SwiftUI
import EasyStreamCore
import WebRTC

public struct ProgramFeedWidgetLayer: Identifiable, Equatable {
    public let id: UUID
    public let configuration: BroadcastWidgetConfiguration
    public let logoURL: URL?
    public let isLive: Bool
    public let isEditing: Bool

    public init(
        id: UUID,
        configuration: BroadcastWidgetConfiguration,
        logoURL: URL?,
        isLive: Bool,
        isEditing: Bool = false
    ) {
        self.id = id
        self.configuration = configuration
        self.logoURL = logoURL
        self.isLive = isLive
        self.isEditing = isEditing
    }
}

public struct ProgramFeedView: View {
    let programDisplayTrack: RTCVideoTrack?
    let outgoingProgramTrack: RTCVideoTrack?
    let isTransitioning: Bool
    let transitionProgress: Double
    let transitionKind: SwitchTransitionKind
    let widgetLayers: [ProgramFeedWidgetLayer]
    let fullScreenResource: BroadcastResource?
    let fullScreenFileURL: URL?
    let fullScreenIsLive: Bool
    let isWidgetPlacementEditing: Bool
    let editingPlacement: Binding<BroadcastWidgetPlacement>?
    let emptyStatusMessage: String

    public init(
        programDisplayTrack: RTCVideoTrack?,
        outgoingProgramTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        transitionProgress: Double,
        transitionKind: SwitchTransitionKind,
        widgetLayers: [ProgramFeedWidgetLayer],
        fullScreenResource: BroadcastResource? = nil,
        fullScreenFileURL: URL? = nil,
        fullScreenIsLive: Bool = false,
        isWidgetPlacementEditing: Bool = false,
        editingPlacement: Binding<BroadcastWidgetPlacement>? = nil,
        emptyStatusMessage: String = "Sin programa"
    ) {
        self.programDisplayTrack = programDisplayTrack
        self.outgoingProgramTrack = outgoingProgramTrack
        self.isTransitioning = isTransitioning
        self.transitionProgress = transitionProgress
        self.transitionKind = transitionKind
        self.widgetLayers = widgetLayers
        self.fullScreenResource = fullScreenResource
        self.fullScreenFileURL = fullScreenFileURL
        self.fullScreenIsLive = fullScreenIsLive
        self.isWidgetPlacementEditing = isWidgetPlacementEditing
        self.editingPlacement = editingPlacement
        self.emptyStatusMessage = emptyStatusMessage
    }

    public var body: some View {
        ZStack {
            if let displayTrack = programDisplayTrack {
                TransitionProgramView(
                    outgoingTrack: isTransitioning ? outgoingProgramTrack : nil,
                    incomingTrack: displayTrack,
                    progress: isTransitioning ? transitionProgress : 1,
                    kind: transitionKind
                )
            } else if widgetLayers.isEmpty, fullScreenResource == nil {
                ContentUnavailableView {
                    Label("Sin programa", systemImage: "tv.slash")
                } description: {
                    Text(emptyStatusMessage)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white.opacity(0.7))
            }

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
                .background(Color.black.opacity(0.01))
            }

            ForEach(widgetLayers) { layer in
                if layer.isEditing, let placement = editingPlacement {
                    BroadcastWidgetCanvas(
                        configuration: layer.configuration,
                        logoURL: layer.logoURL,
                        isEditing: isWidgetPlacementEditing,
                        isLive: layer.isLive,
                        placement: placement
                    )
                } else {
                    BroadcastWidgetCanvas(
                        configuration: layer.configuration,
                        logoURL: layer.logoURL,
                        isEditing: false,
                        isLive: layer.isLive,
                        placement: .constant(layer.configuration.placement)
                    )
                }
            }
        }
    }
}
