import Foundation

/// Drops preview-tier frames from replacing the on-air PROG bus during take handoff.
public enum ProgramFrameQualityGate {
    /// Preview transport is 426×240 — PROG must exceed this band.
    public static let minimumOnAirWidth = 400
    public static let minimumOnAirHeight = 280

    public static func acceptsOnAirFrame(width: Int, height: Int) -> Bool {
        width > minimumOnAirWidth && height > minimumOnAirHeight
    }
}
