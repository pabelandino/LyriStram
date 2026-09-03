import EasyStreamCore
import WebRTC
import EasyStreamVideoPipeline

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
        guard let frame else { return }
        ProgramFrameTelemetryRegistry.live.recordFrame(
            busSlot: slot.busSlot,
            width: Int(frame.width),
            height: Int(frame.height)
        )
        compositor?.receive(frame, slot: slot)
    }
}

private extension BroadcastMetalVideoSink.Slot {
    var busSlot: ProgramFrameBusSlot {
        switch self {
        case .outgoing: .programOutgoing
        case .incoming: .programIncoming
        case .program: .programOnAir
        }
    }
}

typealias ProgramTransitionVideoSink = BroadcastMetalVideoSink
typealias ProgramTransitionMetalCompositor = BroadcastMetalCompositor
