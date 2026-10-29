import SwiftUI
import EasyStreamCore

/// Preview/draft overlay — allowed to re-render freely without touching the program video bus.
public struct PreviewWidgetOverlayView: View {
    let layers: [ProgramFeedWidgetLayer]
    let isPlacementEditing: Bool
    let allowsMotion: Bool
    @Binding var editingPlacement: BroadcastWidgetPlacement

    public init(
        layers: [ProgramFeedWidgetLayer],
        isPlacementEditing: Bool,
        editingPlacement: Binding<BroadcastWidgetPlacement>,
        allowsMotion: Bool? = nil
    ) {
        self.layers = layers
        self.isPlacementEditing = isPlacementEditing
        self._editingPlacement = editingPlacement
        self.allowsMotion = allowsMotion ?? !isPlacementEditing
    }

    public var body: some View {
        ZStack {
            ForEach(layers) { layer in
                BroadcastWidgetCanvas(
                    configuration: layer.configuration,
                    logoURL: layer.logoURL,
                    isEditing: isPlacementEditing,
                    isLive: false,
                    allowsMotion: allowsMotion,
                    placement: $editingPlacement
                )
            }
        }
    }
}
