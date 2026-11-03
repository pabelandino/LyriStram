import EasyStreamCore
import WebRTC

/// Transport-layer decode policy — mutates only tracks whose role changed (avoids decoder storms).
@MainActor
enum DirectorRemoteVideoTrackPolicy {
    private static var lastDecodeEnabled: [CameraSourceID: Bool] = [:]
    private static var lastTrackIdentity: [CameraSourceID: ObjectIdentifier] = [:]

    static func applyDiff(
        sources: [ConnectedCameraSource],
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?,
        assignmentFor: (CameraSourceID) -> CameraSwitcherAssignment
    ) {
        let connectedWithVideo = sources.filter {
            $0.connectionState == .connected && $0.videoTrack != nil
        }.count
        let decodeAllConnectedFeeds = connectedWithVideo <= 8

        var activeIDs = Set<CameraSourceID>()
        for source in sources {
            activeIDs.insert(source.id)
            guard let track = source.videoTrack else { continue }
            let shouldDecode = DirectorLiveOutputGuard.shouldKeepTrackDecoding(
                sourceID: source.id,
                programSourceID: programSourceID,
                previewSourceID: previewSourceID,
                assignmentIsActive: assignmentFor(source.id).isActive,
                decodeAllConnectedFeeds: decodeAllConnectedFeeds
            )
            let trackIdentity = ObjectIdentifier(track)
            let previousDecode = lastDecodeEnabled[source.id]
            let previousTrack = lastTrackIdentity[source.id]
            guard previousDecode != shouldDecode || previousTrack != trackIdentity else { continue }
            track.isEnabled = shouldDecode
            lastDecodeEnabled[source.id] = shouldDecode
            lastTrackIdentity[source.id] = trackIdentity
        }
        for staleID in lastDecodeEnabled.keys where !activeIDs.contains(staleID) {
            lastDecodeEnabled.removeValue(forKey: staleID)
            lastTrackIdentity.removeValue(forKey: staleID)
        }
    }

    static func invalidate(sourceID: CameraSourceID) {
        lastDecodeEnabled.removeValue(forKey: sourceID)
        lastTrackIdentity.removeValue(forKey: sourceID)
    }

    static func reset() {
        lastDecodeEnabled.removeAll()
        lastTrackIdentity.removeAll()
    }
}
