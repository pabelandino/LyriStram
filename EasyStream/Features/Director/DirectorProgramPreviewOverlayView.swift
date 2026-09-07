import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Draft/preview layer — isolated from the live output video bus.
struct DirectorProgramPreviewOverlayView: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
        ZStack {
            if let previewFullScreen = mediaViewModel.previewFullScreenGraphicResource {
                BroadcastResourceDisplayView(
                    resource: previewFullScreen,
                    fileURL: mediaViewModel.fileURL(for: previewFullScreen),
                    widgetConfiguration: nil,
                    logoURL: nil,
                    isLive: false,
                    isEditingWidget: false,
                    widgetPlacement: .constant(BroadcastWidgetPlacement())
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.yellow.opacity(0.85), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                }
            }

            if !mediaViewModel.previewOverlayWidgetLayers.isEmpty {
                PreviewWidgetOverlayView(
                    layers: mediaViewModel.previewOverlayWidgetLayers.map {
                        ProgramFeedWidgetLayer(
                            id: $0.id,
                            configuration: $0.configuration,
                            logoURL: $0.logoURL,
                            isLive: false,
                            isEditing: true
                        )
                    },
                    isPlacementEditing: mediaViewModel.isWidgetPlacementEditing,
                    editingPlacement: $mediaViewModel.draftWidgetConfiguration.placement
                )
            }
        }
    }
}
