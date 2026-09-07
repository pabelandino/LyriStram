#pragma once

#include <cstdint>
#include <mutex>

#ifdef __OBJC__
#import <CoreVideo/CoreVideo.h>
#else
typedef struct __CVBuffer *CVPixelBufferRef;
#endif

namespace esvb {

enum class BusLane : std::uint8_t {
    ProgramOnAir = 0,
    ProgramOutgoing = 1,
    ProgramIncoming = 2,
};

struct DisplayFrame {
    CVPixelBufferRef pixelBuffer = nullptr;
    std::uint32_t width = 0;
    std::uint32_t height = 0;
    bool isNV12 = false;
    std::uint64_t sequence = 0;
};

/// Thread-safe triple-buffered CVPixelBuffer bus — decode threads push, Metal reads `hold`.
class ProgramFrameNativeBus {
public:
    static ProgramFrameNativeBus &shared();

    static constexpr std::size_t kRingCapacity = 3;

    void push(BusLane lane, CVPixelBufferRef buffer, bool isNV12);
    /// Copies the display hold into `out`, retaining `pixelBuffer` (+1).
    bool copyDisplayFrame(BusLane lane, DisplayFrame &out) const;
    static void releaseDisplayFrame(DisplayFrame &frame);

    /// Atomically copies incoming hold → on-air hold (retains buffer before any sink rebind).
    void promoteIncomingToOnAir();

    void clearTransitionLanes();
    void clearOnAirLane();
    void clearAll();

private:
    ProgramFrameNativeBus() = default;

    struct LaneState {
        DisplayFrame ring[kRingCapacity]{};
        std::size_t writeIndex = 0;
        DisplayFrame hold{};
        bool holdValid = false;
        std::uint64_t sequence = 0;
    };

    static void assignFrame(DisplayFrame &dest,
                            CVPixelBufferRef buffer,
                            std::uint32_t width,
                            std::uint32_t height,
                            bool isNV12,
                            std::uint64_t sequence);
    static void releaseFrame(DisplayFrame &frame);
    void publishHold(LaneState &lane, CVPixelBufferRef buffer, bool isNV12);

    mutable std::mutex mutex_;
    LaneState lanes_[3]{};
};

} // namespace esvb
