import Foundation

/// Drops preview-tier frames from replacing the on-air PROG bus during take handoff.
public enum ProgramFrameQualityGate {
    /// Preview transport is 426×240 — PROG must exceed this band.
    public static let minimumOnAirWidth = 400
    /// WebRTC ramp frames (e.g. 480×270) stay live; 426×240 preview tier stays out.
    public static let minimumOnAirHeight = 270

    public static func acceptsOnAirFrame(width: Int, height: Int) -> Bool {
        width > minimumOnAirWidth && height >= minimumOnAirHeight
    }

    /// True when a frame matches the director's configured PROG monitor preset (~12% encoder tolerance).
    public static func meetsConfiguredProgramPreset(width: Int, height: Int) -> Bool {
        let spec = CameraTransportProfile.directorQuality.effectiveSettings().progPreset.streamSpec
        let minWidth = Int(Double(spec.width) * 0.88)
        let minHeight = Int(Double(spec.height) * 0.88)
        return width >= minWidth && height >= minHeight
    }

    /// Live ramp frames allowed during cut grace — excludes standby/preview (320×180) flashes.
    public static func acceptsRampHoldFrame(width: Int, height: Int) -> Bool {
        width > minimumOnAirWidth && height >= minimumOnAirHeight
    }
}
