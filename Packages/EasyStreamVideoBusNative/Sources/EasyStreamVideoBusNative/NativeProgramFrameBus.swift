import CoreVideo
import EasyStreamCore
import Foundation
import simd

/// Swift façade over the C++ `ProgramFrameNativeBus` (IOSurface-backed ring buffer).
public enum NativeProgramFrameBus: Sendable {
    public struct DisplayFrame {
        public let pixelBuffer: CVPixelBuffer
        public let contentSize: SIMD2<Float>
        public let isNV12: Bool
        public let sequence: UInt64
    }

    public static func push(lane: ProgramFrameBusSlot, pixelBuffer: CVPixelBuffer, isNV12: Bool) {
        esvb_bus_push(lane.nativeLane, pixelBuffer, isNV12)
    }

    public static func copyDisplayFrame(for lane: ProgramFrameBusSlot) -> DisplayFrame? {
        var buffer: CVPixelBuffer?
        var width: UInt32 = 0
        var height: UInt32 = 0
        var isNV12 = false
        var sequence: UInt64 = 0

        guard esvb_bus_copy_display_pixel_buffer(
            lane.nativeLane,
            &buffer,
            &width,
            &height,
            &isNV12,
            &sequence
        ), let buffer else {
            return nil
        }

        return DisplayFrame(
            pixelBuffer: buffer,
            contentSize: SIMD2(Float(width), Float(height)),
            isNV12: isNV12,
            sequence: sequence
        )
    }

    public static func promoteIncomingToOnAir() {
        esvb_bus_promote_incoming_to_onair()
    }

    public static func clearTransitionLanes() {
        esvb_bus_clear_transition_lanes()
    }

    public static func clearOnAirLane() {
        esvb_bus_clear_on_air_lane()
    }

    public static func clearAll() {
        esvb_bus_clear_all()
    }
}

private extension ProgramFrameBusSlot {
    var nativeLane: ESVBBusLane {
        switch self {
        case .programOnAir: ESVBBusLaneProgramOnAir
        case .programOutgoing: ESVBBusLaneProgramOutgoing
        case .programIncoming: ESVBBusLaneProgramIncoming
        }
    }
}

@_silgen_name("esvb_bus_push")
private func esvb_bus_push(_ lane: ESVBBusLane, _ buffer: CVPixelBuffer, _ isNV12: Bool)

@_silgen_name("esvb_bus_copy_display_pixel_buffer")
private func esvb_bus_copy_display_pixel_buffer(
    _ lane: ESVBBusLane,
    _ outBuffer: UnsafeMutablePointer<CVPixelBuffer?>,
    _ outWidth: UnsafeMutablePointer<UInt32>?,
    _ outHeight: UnsafeMutablePointer<UInt32>?,
    _ outIsNV12: UnsafeMutablePointer<Bool>?,
    _ outSequence: UnsafeMutablePointer<UInt64>?
) -> Bool

@_silgen_name("esvb_bus_promote_incoming_to_onair")
private func esvb_bus_promote_incoming_to_onair()

@_silgen_name("esvb_bus_clear_transition_lanes")
private func esvb_bus_clear_transition_lanes()

@_silgen_name("esvb_bus_clear_on_air_lane")
private func esvb_bus_clear_on_air_lane()

@_silgen_name("esvb_bus_clear_all")
private func esvb_bus_clear_all()

private typealias ESVBBusLane = UInt8
private let ESVBBusLaneProgramOnAir: ESVBBusLane = 0
private let ESVBBusLaneProgramOutgoing: ESVBBusLane = 1
private let ESVBBusLaneProgramIncoming: ESVBBusLane = 2
