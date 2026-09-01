import Foundation
import Observation
import EasyStreamCore
import EasyStreamUIComponents
import WebRTC

@MainActor
@Observable
final class DirectorProgramOutputStore {
    static let shared = DirectorProgramOutputStore()

    var settings: ProgramOutputSettings = ProgramOutputPreferencesStore.load() {
        didSet { ProgramOutputPreferencesStore.save(settings) }
    }

    private(set) var isWindowOpen = false

    var programDisplayTrack: RTCVideoTrack?
    var outgoingProgramTrack: RTCVideoTrack?
    var isTransitioning = false
    var transitionProgress: Double = 1
    var transitionKind: SwitchTransitionKind = .cut
    var programSourceName: String?
    var widgetLayers: [ProgramFeedWidgetLayer] = []
    var fullScreenResource: BroadcastResource?
    var fullScreenFileURL: URL?
    var fullScreenIsLive = false
    var emptyStatusMessage = "Sin programa"

    private init() {
        var loaded = ProgramOutputPreferencesStore.load()
        loaded.isEnabled = false
        settings = loaded
        isWindowOpen = false
#if os(macOS)
        sanitizeScreenSelection()
#endif
    }

#if os(macOS)
    /// External program output must start disabled each launch; stale windows block the main UI.
    func resetExternalOutputForLaunch() {
        settings.isEnabled = false
        isWindowOpen = false
        sanitizeScreenSelection()
        ProgramOutputWindowPlacement.dismissStaleOutputOnLaunch()
    }

    func sanitizeScreenSelection() {
        guard let externalIndex = ProgramOutputDisplayDiscovery.preferredExternalScreenIndex() else {
            settings.selectedScreenIndex = 0
            return
        }
        if ProgramOutputDisplayDiscovery.validatedExternalScreenIndex(settings.selectedScreenIndex) == nil {
            settings.selectedScreenIndex = externalIndex
        }
    }
#endif

    func markWindowOpen() {
        isWindowOpen = true
    }

    func markWindowClosed() {
        isWindowOpen = false
#if os(macOS)
        ProgramOutputWindowPlacement.restorePresentationOptionsIfNeeded()
#endif
    }

    func syncAirGraphics(
        widgetLayers: [ProgramFeedWidgetLayer],
        fullScreenResource: BroadcastResource?,
        fullScreenFileURL: URL?,
        fullScreenIsLive: Bool
    ) {
        guard widgetLayers != self.widgetLayers
            || fullScreenResource?.id != self.fullScreenResource?.id
            || fullScreenFileURL != self.fullScreenFileURL
            || fullScreenIsLive != self.fullScreenIsLive
        else { return }

        self.widgetLayers = widgetLayers
        self.fullScreenResource = fullScreenResource
        self.fullScreenFileURL = fullScreenFileURL
        self.fullScreenIsLive = fullScreenIsLive
    }

    func syncVideoBus(
        programDisplayTrack: RTCVideoTrack?,
        outgoingProgramTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        transitionProgress: Double,
        transitionKind: SwitchTransitionKind,
        programSourceName: String?,
        emptyStatusMessage: String
    ) {
        let tracksChanged = programDisplayTrack !== self.programDisplayTrack
            || outgoingProgramTrack !== self.outgoingProgramTrack
        let transitionMetaChanged = isTransitioning != self.isTransitioning
            || transitionKind != self.transitionKind
        let progressChanged = abs(transitionProgress - self.transitionProgress) > (1.0 / 60.0)
        let labelsChanged = programSourceName != self.programSourceName
            || emptyStatusMessage != self.emptyStatusMessage

        guard tracksChanged || transitionMetaChanged || progressChanged || labelsChanged else { return }

        self.programDisplayTrack = programDisplayTrack
        self.outgoingProgramTrack = outgoingProgramTrack
        self.isTransitioning = isTransitioning
        self.transitionProgress = transitionProgress
        self.transitionKind = transitionKind
        self.programSourceName = programSourceName
        self.emptyStatusMessage = emptyStatusMessage
    }

    func sync(
        programDisplayTrack: RTCVideoTrack?,
        outgoingProgramTrack: RTCVideoTrack?,
        isTransitioning: Bool,
        transitionProgress: Double,
        transitionKind: SwitchTransitionKind,
        programSourceName: String?,
        widgetLayers: [ProgramFeedWidgetLayer],
        fullScreenResource: BroadcastResource?,
        fullScreenFileURL: URL?,
        fullScreenIsLive: Bool,
        emptyStatusMessage: String
    ) {
        syncVideoBus(
            programDisplayTrack: programDisplayTrack,
            outgoingProgramTrack: outgoingProgramTrack,
            isTransitioning: isTransitioning,
            transitionProgress: transitionProgress,
            transitionKind: transitionKind,
            programSourceName: programSourceName,
            emptyStatusMessage: emptyStatusMessage
        )
        syncAirGraphics(
            widgetLayers: widgetLayers,
            fullScreenResource: fullScreenResource,
            fullScreenFileURL: fullScreenFileURL,
            fullScreenIsLive: fullScreenIsLive
        )
    }
}
