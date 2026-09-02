import WebRTC
import EasyStreamCore
#if canImport(UIKit)
import UIKit
#endif

/// Limits live WebRTC decoders on constrained devices (iPhone Director only).
public enum DirectorPreviewTileTrackPolicy {
    public static func liveTileTrack(
        for sourceID: CameraSourceID,
        track: RTCVideoTrack?,
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?
    ) -> RTCVideoTrack? {
        guard track != nil else { return nil }

#if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Program is shown in the main program monitor — skip duplicate decode in tiles.
            guard sourceID == previewSourceID, previewSourceID != programSourceID else {
                return nil
            }
        }
#endif

        return track
    }
}
