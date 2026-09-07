import Foundation
import EasyStreamCore

public enum SwitcherEvent: Sendable, Equatable {
    case previewChanged(CameraSourceID?)
    case programChanged(CameraSourceID?)
    case programAudioChanged(CameraSourceID?)
    case fallbackChanged(CameraSourceID?)
    case transitionChanged(SwitchTransition)
}

/// Manages Preview / Program selection and transitions.
public actor SwitcherEngine {
    private var snapshot = SwitcherSnapshot()
    private var availableSources: Set<CameraSourceID> = []

    public init() {}

    public var state: SwitcherSnapshot { snapshot }

    public func registerSource(_ id: CameraSourceID) -> SwitcherEvent? {
        guard availableSources.insert(id).inserted else { return nil }

        var events: [SwitcherEvent] = []

        // Preview is operator-selected — auto-arming decodes/streams immediately and spikes CPU.
        if snapshot.programAudioSourceID == nil {
            snapshot.programAudioSourceID = id
            events.append(.programAudioChanged(id))
        }
        if snapshot.fallbackSourceID == nil {
            snapshot.fallbackSourceID = id
            events.append(.fallbackChanged(id))
        }

        return events.first
    }

    public func unregisterSource(_ id: CameraSourceID) -> [SwitcherEvent] {
        availableSources.remove(id)
        var events: [SwitcherEvent] = []

        if snapshot.previewSourceID == id {
            snapshot.previewSourceID = availableSources.sorted { $0.rawValue.uuidString < $1.rawValue.uuidString }.first
            events.append(.previewChanged(snapshot.previewSourceID))
        }

        if snapshot.programAudioSourceID == id {
            snapshot.programAudioSourceID = pickAudioFallback(excluding: id)
            events.append(.programAudioChanged(snapshot.programAudioSourceID))
        }

        if snapshot.fallbackSourceID == id {
            snapshot.fallbackSourceID = availableSources.first
            events.append(.fallbackChanged(snapshot.fallbackSourceID))
        }

        if snapshot.programSourceID == id {
            let next = snapshot.fallbackSourceID ?? snapshot.previewSourceID ?? availableSources.first
            snapshot.programSourceID = next
            events.append(.programChanged(next))
        }

        return events
    }

    @discardableResult
    public func setPreview(_ id: CameraSourceID) -> SwitcherEvent? {
        guard availableSources.contains(id) else { return nil }
        guard snapshot.previewSourceID != id else { return nil }
        snapshot.previewSourceID = id
        return .previewChanged(id)
    }

    @discardableResult
    public func takePreviewToProgram(transition: SwitchTransition? = nil) -> [SwitcherEvent] {
        guard let preview = snapshot.previewSourceID else { return [] }
        return take(to: preview, transition: transition)
    }

    @discardableResult
    public func take(to id: CameraSourceID, transition: SwitchTransition? = nil) -> [SwitcherEvent] {
        guard availableSources.contains(id) else { return [] }
        guard snapshot.programSourceID != id else { return [] }
        if let transition {
            snapshot.preferredTransition = transition
        }

        let outgoingProgram = snapshot.programSourceID
        snapshot.programSourceID = id

        var events: [SwitcherEvent] = [.programChanged(id)]

        if let outgoingProgram, outgoingProgram != id {
            snapshot.previewSourceID = outgoingProgram
            events.append(.previewChanged(outgoingProgram))
        } else {
            let nextPreview = availableSources
                .sorted { $0.rawValue.uuidString < $1.rawValue.uuidString }
                .first { $0 != id }
            snapshot.previewSourceID = nextPreview ?? id
            if let nextPreview, nextPreview != id {
                events.append(.previewChanged(nextPreview))
            }
        }

        return events
    }

    @discardableResult
    public func setProgramAudioSource(_ id: CameraSourceID) -> SwitcherEvent? {
        guard availableSources.contains(id) else { return nil }
        guard snapshot.programAudioSourceID != id else { return nil }
        snapshot.programAudioSourceID = id
        return .programAudioChanged(id)
    }

    @discardableResult
    public func setPreferredTransition(_ transition: SwitchTransition) -> SwitcherEvent? {
        guard snapshot.preferredTransition != transition else { return nil }
        snapshot.preferredTransition = transition
        return .transitionChanged(transition)
    }

    public func setFallback(_ id: CameraSourceID?) -> SwitcherEvent? {
        if let id, !availableSources.contains(id) { return nil }
        guard snapshot.fallbackSourceID != id else { return nil }
        snapshot.fallbackSourceID = id
        return .fallbackChanged(id)
    }

    private func pickAudioFallback(excluding excluded: CameraSourceID) -> CameraSourceID? {
        availableSources
            .filter { $0 != excluded }
            .sorted { $0.rawValue.uuidString < $1.rawValue.uuidString }
            .first
    }
}

// Backward-compatible aliases
public extension SwitcherEngine {
    func cut(to id: CameraSourceID, transition: SwitchTransition = .cut) -> [SwitcherEvent] {
        take(to: id, transition: transition)
    }

    func cutPreviewToProgram(transition: SwitchTransition = .cut) -> [SwitcherEvent] {
        takePreviewToProgram(transition: transition)
    }
}
