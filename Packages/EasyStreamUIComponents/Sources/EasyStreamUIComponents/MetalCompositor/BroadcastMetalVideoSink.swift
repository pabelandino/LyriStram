import WebRTC

/// Receives WebRTC frames and forwards them to `BroadcastMetalCompositor`.
final class BroadcastMetalVideoSink: NSObject, RTCVideoRenderer {
    enum Slot {
        case outgoing
        case incoming
        case program
    }

    let slot: Slot
    weak var compositor: BroadcastMetalCompositor?

    init(slot: Slot) {
        self.slot = slot
    }

    func setSize(_ size: CGSize) {}

    func renderFrame(_ frame: RTCVideoFrame?) {
        compositor?.receive(frame, slot: slot)
    }
}

typealias ProgramTransitionVideoSink = BroadcastMetalVideoSink
typealias ProgramTransitionMetalCompositor = BroadcastMetalCompositor
