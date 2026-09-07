import Foundation
import EasyStreamCore

/// Central policy: never disturb the live program bus while on-air unless explicitly taking to program.
@MainActor
enum DirectorLiveOutputGuard {
    static func isProgramBusLocked(
        programSourceID: CameraSourceID?,
        isTransitioning: Bool,
        isPublishing: Bool
    ) -> Bool {
        programSourceID != nil || isTransitioning || isPublishing
    }

    static func mayRestartProgramDecoder(
        programSourceID: CameraSourceID?,
        isTransitioning: Bool,
        isPublishing: Bool,
        from old: DirectorMonitorQualitySettings,
        to new: DirectorMonitorQualitySettings
    ) -> Bool {
        guard !isProgramBusLocked(
            programSourceID: programSourceID,
            isTransitioning: isTransitioning,
            isPublishing: isPublishing
        ) else {
            return false
        }
        return old.progPreset != new.progPreset
            || old.prefetchTakeTarget != new.prefetchTakeTarget
            || old.pauseIdleCameraStreams != new.pauseIdleCameraStreams
    }

    static func mergedQualityUpdate(
        programSourceID: CameraSourceID?,
        isTransitioning: Bool,
        isPublishing: Bool,
        current: DirectorMonitorQualitySettings,
        proposed: DirectorMonitorQualitySettings
    ) -> DirectorMonitorQualitySettings {
        guard isTransitioning else {
            return proposed
        }
        // During animated take, avoid mid-transition transport churn; cut applies on next take.
        var safe = proposed
        safe.progPreset = current.progPreset
        safe.prefetchTakeTarget = current.prefetchTakeTarget
        safe.pauseIdleCameraStreams = current.pauseIdleCameraStreams
        return safe
    }

    static func shouldKeepTrackDecoding(
        sourceID: CameraSourceID,
        programSourceID: CameraSourceID?,
        previewSourceID: CameraSourceID?,
        assignmentIsActive: Bool
    ) -> Bool {
        if sourceID == programSourceID || sourceID == previewSourceID {
            return true
        }
        return assignmentIsActive
    }
}
