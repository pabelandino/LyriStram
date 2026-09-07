import SwiftUI
import EasyStreamCore

/// Widget overlay for committed air graphics.
public struct StableWidgetOverlayView: View {
    let layers: [ProgramFeedWidgetLayer]
    let onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    public init(
        layers: [ProgramFeedWidgetLayer],
        onWidgetLiveAutoDismiss: ((UUID) -> Void)? = nil
    ) {
        self.layers = layers
        self.onWidgetLiveAutoDismiss = onWidgetLiveAutoDismiss
    }

    public var body: some View {
        ZStack {
            ForEach(layers) { layer in
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
        .animation(nil, value: layers.map(\.id))
    }
}
