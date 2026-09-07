#include "ProgramFrameNativeBus.hpp"

#import <CoreVideo/CoreVideo.h>

namespace esvb {

ProgramFrameNativeBus &ProgramFrameNativeBus::shared() {
    static ProgramFrameNativeBus instance;
    return instance;
}

void ProgramFrameNativeBus::releaseFrame(DisplayFrame &frame) {
    if (frame.pixelBuffer != nullptr) {
        CVPixelBufferRelease(frame.pixelBuffer);
        frame.pixelBuffer = nullptr;
    }
    frame.width = 0;
    frame.height = 0;
    frame.isNV12 = false;
    frame.sequence = 0;
}

void ProgramFrameNativeBus::assignFrame(DisplayFrame &dest,
                                        CVPixelBufferRef buffer,
                                        std::uint32_t width,
                                        std::uint32_t height,
                                        bool isNV12,
                                        std::uint64_t sequence) {
    releaseFrame(dest);
    if (buffer != nullptr) {
        CVPixelBufferRetain(buffer);
        dest.pixelBuffer = buffer;
    }
    dest.width = width;
    dest.height = height;
    dest.isNV12 = isNV12;
    dest.sequence = sequence;
}

void ProgramFrameNativeBus::publishHold(LaneState &lane, CVPixelBufferRef buffer, bool isNV12) {
    if (buffer == nullptr) {
        return;
    }

    const std::uint32_t width = static_cast<std::uint32_t>(CVPixelBufferGetWidth(buffer));
    const std::uint32_t height = static_cast<std::uint32_t>(CVPixelBufferGetHeight(buffer));
    lane.sequence += 1;

    assignFrame(lane.ring[lane.writeIndex], buffer, width, height, isNV12, lane.sequence);
    lane.writeIndex = (lane.writeIndex + 1) % kRingCapacity;

    assignFrame(lane.hold, buffer, width, height, isNV12, lane.sequence);
    lane.holdValid = true;
}

void ProgramFrameNativeBus::push(BusLane lane, CVPixelBufferRef buffer, bool isNV12) {
    if (buffer == nullptr) {
        return;
    }

    const auto index = static_cast<std::size_t>(lane);
    if (index >= 3) {
        return;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    publishHold(lanes_[index], buffer, isNV12);
}

bool ProgramFrameNativeBus::copyDisplayFrame(BusLane lane, DisplayFrame &out) const {
    const auto index = static_cast<std::size_t>(lane);
    if (index >= 3) {
        return false;
    }

    std::lock_guard<std::mutex> lock(mutex_);
    const LaneState &state = lanes_[index];
    if (!state.holdValid || state.hold.pixelBuffer == nullptr) {
        return false;
    }

    assignFrame(out, state.hold.pixelBuffer, state.hold.width, state.hold.height, state.hold.isNV12,
                state.hold.sequence);
    return true;
}

void ProgramFrameNativeBus::releaseDisplayFrame(DisplayFrame &frame) {
    releaseFrame(frame);
}

void ProgramFrameNativeBus::promoteIncomingToOnAir() {
    std::lock_guard<std::mutex> lock(mutex_);
    LaneState &incoming = lanes_[static_cast<std::size_t>(BusLane::ProgramIncoming)];
    LaneState &program = lanes_[static_cast<std::size_t>(BusLane::ProgramOnAir)];

    if (!incoming.holdValid || incoming.hold.pixelBuffer == nullptr) {
        return;
    }

    program.sequence += 1;
    assignFrame(program.hold, incoming.hold.pixelBuffer, incoming.hold.width, incoming.hold.height,
                incoming.hold.isNV12, program.sequence);
    program.holdValid = true;

    assignFrame(program.ring[program.writeIndex], incoming.hold.pixelBuffer, incoming.hold.width,
                incoming.hold.height, incoming.hold.isNV12, program.sequence);
    program.writeIndex = (program.writeIndex + 1) % kRingCapacity;
}

void ProgramFrameNativeBus::clearTransitionLanes() {
    std::lock_guard<std::mutex> lock(mutex_);
    for (std::size_t i = 0; i < 3; ++i) {
        if (i == static_cast<std::size_t>(BusLane::ProgramOnAir)) {
            continue;
        }
        LaneState &lane = lanes_[i];
        for (std::size_t r = 0; r < kRingCapacity; ++r) {
            releaseFrame(lane.ring[r]);
        }
        releaseFrame(lane.hold);
        lane = LaneState{};
    }
}

void ProgramFrameNativeBus::clearOnAirLane() {
    std::lock_guard<std::mutex> lock(mutex_);
    LaneState &lane = lanes_[static_cast<std::size_t>(BusLane::ProgramOnAir)];
    for (std::size_t r = 0; r < kRingCapacity; ++r) {
        releaseFrame(lane.ring[r]);
    }
    releaseFrame(lane.hold);
    lane = LaneState{};
}

void ProgramFrameNativeBus::clearAll() {
    std::lock_guard<std::mutex> lock(mutex_);
    for (std::size_t i = 0; i < 3; ++i) {
        LaneState &lane = lanes_[i];
        for (std::size_t r = 0; r < kRingCapacity; ++r) {
            releaseFrame(lane.ring[r]);
        }
        releaseFrame(lane.hold);
        lane = LaneState{};
    }
}

} // namespace esvb
