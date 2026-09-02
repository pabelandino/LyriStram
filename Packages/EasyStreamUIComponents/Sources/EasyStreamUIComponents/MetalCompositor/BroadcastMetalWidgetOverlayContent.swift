import SwiftUI
import EasyStreamCore

/// Widget / full-screen graphics content rasterized into the Metal overlay layer.
struct BroadcastMetalWidgetOverlayContent: View {
    let widgetLayers: [ProgramFeedWidgetLayer]
    let fullScreenResource: BroadcastResource?
    let fullScreenFileURL: URL?
    let fullScreenIsLive: Bool
    let onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    init(
        widgetLayers: [ProgramFeedWidgetLayer],
        fullScreenResource: BroadcastResource? = nil,
        fullScreenFileURL: URL? = nil,
        fullScreenIsLive: Bool = false,
        onWidgetLiveAutoDismiss: ((UUID) -> Void)? = nil
    ) {
        self.widgetLayers = widgetLayers
        self.fullScreenResource = fullScreenResource
        self.fullScreenFileURL = fullScreenFileURL
        self.fullScreenIsLive = fullScreenIsLive
        self.onWidgetLiveAutoDismiss = onWidgetLiveAutoDismiss
    }

    var body: some View {
        ZStack {
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

            ForEach(widgetLayers) { layer in
                BroadcastWidgetCanvas(
                    configuration: layer.configuration,
                    logoURL: layer.logoURL,
                    isEditing: false,
                    isLive: layer.isLive,
                    allowsMotion: layer.isLive,
                    placement: .constant(layer.configuration.placement),
                    onLiveSequenceEnded: layer.isLive ? { onWidgetLiveAutoDismiss?(layer.id) } : nil
                )
                .id(layer.id)
            }
        }
    }
}

extension BroadcastMetalWidgetOverlayContent {
    static func needsContinuousRefresh(for layers: [ProgramFeedWidgetLayer]) -> Bool {
        layers.contains { layer in
            if layer.isLive { return true }
            switch layer.configuration.resolvedTemplate {
            case .animatedLogo, .logo, .ticker, .textBanner, .clock, .countdown:
                return true
            default:
                return false
            }
        }
    }
}
