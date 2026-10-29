import WebRTC
import EasyStreamCore

/// UI adapter for `ProgramPreviewVisibilityPolicy` — keeps WebRTC types out of the domain layer.
@MainActor
public enum DirectorPreviewTileTrackPolicy {
    public static var visibilityPolicy: ProgramPreviewVisibilityPolicy = .directorDefault

    /// Switcher tiles: preview + program receive a live track; idle uses placeholder or JPEG opt-in.
    public static func liveTileTrack(
        for sourceID: CameraSourceID,
        track: RTCVideoTrack?,
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?
    ) -> RTCVideoTrack? {
        guard track != nil else { return nil }
        guard visibilityPolicy.allowsLiveTile(
            sourceIsPreview: sourceID == previewSourceID,
            sourceIsProgram: sourceID == programSourceID,
            previewEqualsProgram: previewSourceID == programSourceID
        ) else {
            return nil
        }
        return track
    }

    /// Phase 2 — lightweight ~2 fps decode for idle tiles.
    public static func shouldAttachTileThumbnail(
        for sourceID: CameraSourceID,
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?
    ) -> Bool {
        visibilityPolicy.shouldAttachTileThumbnail(
            sourceIsPreview: sourceID == previewSourceID,
            sourceIsProgram: sourceID == programSourceID,
            previewEqualsProgram: previewSourceID == programSourceID
        )
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
            sourceIsProgram: sourceID == programSourceID,
            previewEqualsProgram: previewSourceID == programSourceID
        ) else {
            return nil
        }
        return track
    }
}
