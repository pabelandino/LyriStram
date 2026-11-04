import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Committed on-air graphics from the frozen live bus.
struct DirectorProgramAirGraphicsView: View, Equatable {
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

    static func == (lhs: DirectorProgramAirGraphicsView, rhs: DirectorProgramAirGraphicsView) -> Bool {
        lhs.widgetLayers == rhs.widgetLayers
            && lhs.fullScreenResource == rhs.fullScreenResource
            && lhs.fullScreenFileURL == rhs.fullScreenFileURL
            && lhs.fullScreenIsLive == rhs.fullScreenIsLive
    }
}
