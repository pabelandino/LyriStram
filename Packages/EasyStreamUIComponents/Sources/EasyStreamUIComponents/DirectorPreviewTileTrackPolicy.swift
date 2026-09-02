import WebRTC
import EasyStreamCore

/// Limits live WebRTC decoders on director clients to reduce CPU and thermal load.
public enum DirectorPreviewTileTrackPolicy {
    /// Switcher tiles: only the selected preview source receives a live track.
    /// Program is always shown in the main program monitor, not duplicated in tiles.
    public static func liveTileTrack(
        for sourceID: CameraSourceID,
        track: RTCVideoTrack?,
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?
    ) -> RTCVideoTrack? {
        guard track != nil else { return nil }
        guard shouldLimitLiveTiles else { return track }

        guard sourceID == previewSourceID, previewSourceID != programSourceID else {
            return nil
        }
        return track
    }

    /// Preview-monitor hero: withhold program live video when the director already has a PROG monitor.
    public static func previewMonitorHeroTrack(
        for sourceID: CameraSourceID,
        track: RTCVideoTrack?,
        programSourceID: CameraSourceID?,
        suppressProgramHeroLiveVideo: Bool
    ) -> RTCVideoTrack? {
        guard track != nil else { return nil }
        guard suppressProgramHeroLiveVideo, sourceID == programSourceID else {
            return track
        }
        return nil
    }

    /// Preview-monitor grid cells: preview gets live video; other sources stay as placeholders until Phase 2 thumbnails.
    public static func previewMonitorGridTrack(
        for sourceID: CameraSourceID,
        track: RTCVideoTrack?,
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?
    ) -> RTCVideoTrack? {
        guard track != nil else { return nil }
        guard shouldLimitLiveTiles else { return track }

        if sourceID == previewSourceID, previewSourceID != programSourceID {
            return track
        }
        if sourceID != programSourceID {
            return nil
        }
        return nil
    }

    private static var shouldLimitLiveTiles: Bool { true }
}
