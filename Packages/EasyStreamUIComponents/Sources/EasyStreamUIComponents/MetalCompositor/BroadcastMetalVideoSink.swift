import EasyStreamCore
import WebRTC
import EasyStreamVideoPipeline

/// Receives WebRTC frames and forwards them to `ProgramFrameDisplayBus` (decode thread → ring buffer → GPU).
final class BroadcastMetalVideoSink: NSObject, RTCVideoRenderer {
    enum Slot {
        case outgoing
        case incoming
        case program
    }

    let slot: Slot

    init(slot: Slot) {
        self.slot = slot
    }

    func setSize(_ size: CGSize) {}

    func renderFrame(_ frame: RTCVideoFrame?) {
        guard let frame else { return }
        ProgramFrameDisplayBus.shared.enqueue(frame, lane: slot.busSlot)
    }
}

extension BroadcastMetalVideoSink.Slot {
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
