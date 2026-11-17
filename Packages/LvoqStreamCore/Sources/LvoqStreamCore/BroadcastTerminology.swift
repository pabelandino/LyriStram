import Foundation

/// On-air / preview labels used across director chrome.
public enum BroadcastTerminology {
  public static var previewShort: String { BundleLocalization.string("broadcast.preview.short") }
  public static var previewName: String { BundleLocalization.string("broadcast.preview.name") }
  public static var programShort: String { BundleLocalization.string("broadcast.program.short") }
  public static var programName: String { BundleLocalization.string("broadcast.program.name") }
  public static var audioShort: String { BundleLocalization.string("broadcast.audio.short") }
  public static var audioName: String { BundleLocalization.string("broadcast.audio.name") }
  public static var takeAction: String { BundleLocalization.string("broadcast.take.action") }
  public static var takeDescription: String { BundleLocalization.string("broadcast.take.description") }
  public static var leaveAirAction: String { BundleLocalization.string("broadcast.leave.action") }
  public static var leaveAirDescription: String { BundleLocalization.string("broadcast.leave.description") }
}