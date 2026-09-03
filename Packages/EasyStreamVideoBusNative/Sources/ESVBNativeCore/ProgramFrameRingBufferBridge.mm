#include "ProgramFrameRingBufferBridge.h"
#include "ProgramFrameRingBuffer.hpp"

extern "C" const char *esvb_native_bus_version(void) {
    static esvb::ProgramFrameRingBuffer ringBuffer(3);
    (void)ringBuffer;
    return "EasyStreamVideoBusNative/0.1.0";
}
