import Foundation
import Observation

/// Play and stop state for the video that is currently the program plate.
@MainActor
@Observable
public final class BroadcastProgramPlateTransport {
    public static let shared = BroadcastProgramPlateTransport()

    public private(set) var isVideo = false
    public private(set) var isPlaying = false

    private init() {}

    func apply(isVideo: Bool, isPlaying: Bool) {
        self.isVideo = isVideo
        self.isPlaying = isPlaying
    }

    public func playOrPause() {
        if isPlaying {
            BroadcastProgramPlatePlayer.shared.pause()
        } else {
            BroadcastProgramPlatePlayer.shared.resume()
        }
    }

    public func stop() {
        BroadcastProgramPlatePlayer.shared.stopAtStart()
    }
}
