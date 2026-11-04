import Foundation
import Observation
import QuartzCore
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
    /// Bumps only when committed air graphics actually change (not on director UI edits).
    private(set) var revision: UInt64 = 0

    var widgetAutoDismissHandler: ((UUID) -> Void)?

    @ObservationIgnored private var lowerThirdExitTask: Task<Void, Never>?
    @ObservationIgnored private var lowerThirdStartedAt: [UUID: CFTimeInterval] = [:]

    private init() {}

    func requestWidgetAutoDismiss(_ id: UUID) {
        widgetAutoDismissHandler?(id)
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

        let plateChanged = newFullScreen?.id != fullScreenResource?.id
            || newFullScreenURL != fullScreenFileURL
            || newFullScreenLive != fullScreenIsLive
        let graphicsChanged = newLayers != widgetLayers || plateChanged

        guard graphicsChanged else { return }

        widgetLayers = newLayers
        fullScreenResource = newFullScreen
        fullScreenFileURL = newFullScreenURL
        fullScreenIsLive = newFullScreenLive
        revision &+= 1

        // Widgets must not reload the plate. Restarting present() seeks the video back to the start.
        if plateChanged {
            if let resource = fullScreenResource, let url = fullScreenFileURL,
               resource.kind == .image || resource.kind == .video {
                BroadcastProgramPlatePlayer.shared.present(url: url, kind: resource.kind)
            } else {
                BroadcastProgramPlatePlayer.shared.clear()
            }
        }
        BroadcastMetalSpriteBus.shared.publish(widgetLayers)
        scheduleLowerThirdExit(for: widgetLayers)
        DirectorProgramOutputStore.shared.syncAirGraphics(
            widgetLayers: widgetLayers,
            fullScreenResource: fullScreenResource,
            fullScreenFileURL: fullScreenFileURL,
            fullScreenIsLive: fullScreenIsLive
        )
    }

    /// One sleep for the whole lower-third timeline. The shader owns the frames.
    /// Adding or removing another graphic must not restart a lower third that is already counting down.
    private func scheduleLowerThirdExit(for layers: [ProgramFeedWidgetLayer]) {
        lowerThirdExitTask?.cancel()
        let now = CACurrentMediaTime()
        var timed: [(UUID, Double)] = []
        var stillLive: [UUID: CFTimeInterval] = [:]
        for layer in layers {
            let template = layer.configuration.resolvedTemplate
            guard template == .lowerThird || template == .lowerThirdPro else { continue }
            let sequence = LowerThirdSequence.make(
                style: layer.configuration.resolvedLowerThirdStyle,
                hasThirdLine: !layer.configuration.lowerThirdThirdLine.isEmpty,
                animateIn: layer.configuration.animateInSeconds,
                hold: layer.configuration.holdDurationSeconds,
                animateOut: layer.configuration.animateOutSeconds
            )
            let started = lowerThirdStartedAt[layer.id] ?? now
            stillLive[layer.id] = started
            timed.append((layer.id, sequence.totalDuration + 0.4 - (now - started)))
        }
        lowerThirdStartedAt = stillLive
        guard !timed.isEmpty else {
            lowerThirdExitTask = nil
            return
        }
        lowerThirdExitTask = Task { @MainActor in
            let ordered = timed.sorted { $0.1 < $1.1 }
            var elapsed = 0.0
            for item in ordered {
                let wait = item.1 - elapsed
                if wait > 0 {
                    do {
                        try await Task.sleep(for: .seconds(wait))
                    } catch {
                        return
                    }
                }
                guard !Task.isCancelled else { return }
                elapsed = max(elapsed, item.1)
                requestWidgetAutoDismiss(item.0)
            }
        }
    }
}
