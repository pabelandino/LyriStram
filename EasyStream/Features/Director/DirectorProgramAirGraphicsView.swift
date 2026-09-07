import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Committed on-air graphics from the frozen live bus.
struct DirectorProgramAirGraphicsView: View {
    let widgetLayers: [ProgramFeedWidgetLayer]
    let fullScreenResource: BroadcastResource?
    let fullScreenFileURL: URL?
    let fullScreenIsLive: Bool
    let onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    var body: some View {
        ZStack {
            if let fullScreen = fullScreenResource,
               let fileURL = fullScreenFileURL {
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

            StableWidgetOverlayView(
                layers: widgetLayers,
                onWidgetLiveAutoDismiss: onWidgetLiveAutoDismiss
            )
        }
    }
}
