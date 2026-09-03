import WebRTC
import EasyStreamCore

/// UI adapter for `ProgramPreviewVisibilityPolicy` — keeps WebRTC types out of the domain layer.
@MainActor
public enum DirectorPreviewTileTrackPolicy {
    public static var visibilityPolicy: ProgramPreviewVisibilityPolicy = .directorDefault

    /// Switcher tiles: only the selected preview source receives a live track when policy limits decoders.
    public static func liveTileTrack(
        for sourceID: CameraSourceID,
        track: RTCVideoTrack?,
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?
    ) -> RTCVideoTrack? {
        guard track != nil else { return nil }
        guard visibilityPolicy.allowsLiveTile(
            sourceIsPreview: sourceID == previewSourceID,
            previewEqualsProgram: previewSourceID == programSourceID
        ) else {
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
        if sourceID == programSourceID {
            let shouldShowProgramHero = visibilityPolicy.allowsPreviewMonitorHero(
                programHeroEnabled: !suppressProgramHeroLiveVideo
            )
            guard shouldShowProgramHero else { return nil }
        }
        return track
    }

    /// Preview-monitor grid cells: preview gets live video; others wait for Phase 2 thumbnails.
    public static func previewMonitorGridTrack(
        for sourceID: CameraSourceID,
        track: RTCVideoTrack?,
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?
    ) -> RTCVideoTrack? {
        guard track != nil else { return nil }
        guard visibilityPolicy.allowsPreviewMonitorGridCell(
            sourceIsPreview: sourceID == previewSourceID,
            previewEqualsProgram: previewSourceID == programSourceID
        ) else {
            return nil
        }
        return track
    }
}
