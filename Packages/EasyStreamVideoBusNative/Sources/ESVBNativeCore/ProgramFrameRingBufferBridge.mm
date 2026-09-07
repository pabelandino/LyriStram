#include "ProgramFrameRingBufferBridge.h"

#include "ProgramFrameNativeBus.hpp"

static esvb::BusLane laneFromC(ESVBBusLane lane) {
    switch (lane) {
    case ESVBBusLaneProgramOutgoing:
        return esvb::BusLane::ProgramOutgoing;
    case ESVBBusLaneProgramIncoming:
        return esvb::BusLane::ProgramIncoming;
    case ESVBBusLaneProgramOnAir:
    default:
        return esvb::BusLane::ProgramOnAir;
    }
}

extern "C" const char *esvb_native_bus_version(void) {
    return "EasyStreamVideoBusNative/0.3.0";
}

extern "C" void esvb_bus_push(ESVBBusLane lane, CVPixelBufferRef buffer, bool isNV12) {
    esvb::ProgramFrameNativeBus::shared().push(laneFromC(lane), buffer, isNV12);
}

extern "C" bool esvb_bus_copy_display_pixel_buffer(ESVBBusLane lane,
                                                   CVPixelBufferRef *outBuffer,
                                                   uint32_t *outWidth,
                                                   uint32_t *outHeight,
                                                   bool *outIsNV12,
                                                   uint64_t *outSequence) {
    esvb::DisplayFrame frame{};
    if (!esvb::ProgramFrameNativeBus::shared().copyDisplayFrame(laneFromC(lane), frame)) {
        return false;
    }
    if (outBuffer != nullptr) {
        *outBuffer = frame.pixelBuffer;
    } else if (frame.pixelBuffer != nullptr) {
        CVPixelBufferRelease(frame.pixelBuffer);
    }
    if (outWidth != nullptr) {
        *outWidth = frame.width;
    }
    if (outHeight != nullptr) {
        *outHeight = frame.height;
    }
    if (outIsNV12 != nullptr) {
        *outIsNV12 = frame.isNV12;
    }
    if (outSequence != nullptr) {
        *outSequence = frame.sequence;
    }
    return true;
}

extern "C" void esvb_bus_promote_incoming_to_onair(void) {
    esvb::ProgramFrameNativeBus::shared().promoteIncomingToOnAir();
}

extern "C" void esvb_bus_clear_transition_lanes(void) {
    esvb::ProgramFrameNativeBus::shared().clearTransitionLanes();
}

extern "C" void esvb_bus_clear_on_air_lane(void) {
    esvb::ProgramFrameNativeBus::shared().clearOnAirLane();
}

extern "C" void esvb_bus_clear_all(void) {
    esvb::ProgramFrameNativeBus::shared().clearAll();
}
