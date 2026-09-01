import Foundation
import Observation
import EasyStreamCore
import EasyStreamUIComponents

/// Frozen snapshot of graphics that are actually on air.
/// Updated only when live state commits — never while editing drafts in the studio.
@MainActor
@Observable
final class LiveProgramAirStore {
    static let shared = LiveProgramAirStore()

    private(set) var widgetLayers: [ProgramFeedWidgetLayer] = []
    private(set) var fullScreenResource: BroadcastResource?
    private(set) var fullScreenFileURL: URL?
    private(set) var fullScreenIsLive = false
    /// Widget hidden on director monitor while its draft is edited (external output unchanged).
    private(set) var directorEditingWidgetID: UUID?
    /// Bumps only when committed air graphics actually change (not on director UI edits).
    private(set) var revision: UInt64 = 0

    var widgetAutoDismissHandler: ((UUID) -> Void)?

    private init() {}

    func requestWidgetAutoDismiss(_ id: UUID) {
        widgetAutoDismissHandler?(id)
    }

    func setDirectorEditingWidget(_ id: UUID?) {
        guard directorEditingWidgetID != id else { return }
        directorEditingWidgetID = id
    }

    func refresh(from media: BroadcastMediaViewModel) {
        let newLayers = media.committedLiveAirWidgetLayers.map {
            ProgramFeedWidgetLayer(
                id: $0.id,
                configuration: $0.configuration,
                logoURL: $0.logoURL,
                isLive: true,
                isEditing: false
            )
        }

        let newFullScreen: BroadcastResource?
        let newFullScreenURL: URL?
        let newFullScreenLive: Bool
        if let id = media.liveFullScreenGraphicID,
           let resource = media.allResources.first(where: { $0.id == id }) {
            newFullScreen = resource
            newFullScreenURL = media.fileURL(for: resource)
            newFullScreenLive = true
        } else {
            newFullScreen = nil
            newFullScreenURL = nil
            newFullScreenLive = false
        }

        let graphicsChanged = newLayers != widgetLayers
            || newFullScreen?.id != fullScreenResource?.id
            || newFullScreenURL != fullScreenFileURL
            || newFullScreenLive != fullScreenIsLive

        guard graphicsChanged else { return }

        widgetLayers = newLayers
        fullScreenResource = newFullScreen
        fullScreenFileURL = newFullScreenURL
        fullScreenIsLive = newFullScreenLive
        revision &+= 1

        DirectorProgramOutputStore.shared.syncAirGraphics(
            widgetLayers: widgetLayers,
            fullScreenResource: fullScreenResource,
            fullScreenFileURL: fullScreenFileURL,
            fullScreenIsLive: fullScreenIsLive
        )
    }
}
