import EasyStreamCore
import WebRTC

/// Transport-layer decode policy — mutates only tracks whose role changed (avoids decoder storms).
@MainActor
enum DirectorRemoteVideoTrackPolicy {
    private static var lastDecodeEnabled: [CameraSourceID: Bool] = [:]

    static func applyDiff(
        sources: [ConnectedCameraSource],
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?,
        assignmentFor: (CameraSourceID) -> CameraSwitcherAssignment
    ) {
        var activeIDs = Set<CameraSourceID>()
        for source in sources {
            activeIDs.insert(source.id)
            guard let track = source.videoTrack else { continue }
            let shouldDecode = DirectorLiveOutputGuard.shouldKeepTrackDecoding(
                sourceID: source.id,
                programSourceID: programSourceID,
                previewSourceID: previewSourceID,
                assignmentIsActive: assignmentFor(source.id).isActive
            )
            let previous = lastDecodeEnabled[source.id]
            guard previous != shouldDecode else { continue }
            track.isEnabled = shouldDecode
            lastDecodeEnabled[source.id] = shouldDecode
        }
        for staleID in lastDecodeEnabled.keys where !activeIDs.contains(staleID) {
            lastDecodeEnabled.removeValue(forKey: staleID)
        }
    }

    static func reset() {
        lastDecodeEnabled.removeAll()
    }
}
