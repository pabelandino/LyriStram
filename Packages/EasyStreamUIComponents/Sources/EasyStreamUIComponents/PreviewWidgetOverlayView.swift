import SwiftUI
import EasyStreamCore

/// Preview/draft overlay — allowed to re-render freely without touching the program video bus.
public struct PreviewWidgetOverlayView: View {
    let layers: [ProgramFeedWidgetLayer]
    let isPlacementEditing: Bool
    @Binding var editingPlacement: BroadcastWidgetPlacement

    public init(
        layers: [ProgramFeedWidgetLayer],
        isPlacementEditing: Bool,
        editingPlacement: Binding<BroadcastWidgetPlacement>
    ) {
        self.layers = layers
        self.isPlacementEditing = isPlacementEditing
        self._editingPlacement = editingPlacement
    }

    public var body: some View {
        ZStack {
            ForEach(layers) { layer in
                BroadcastWidgetCanvas(
                    configuration: layer.configuration,
                    logoURL: layer.logoURL,
                    isEditing: isPlacementEditing,
                    isLive: false,
                    allowsMotion: !isPlacementEditing,
                    placement: $editingPlacement
                )
            }
        }
    }
}
