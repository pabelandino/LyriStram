#include "ProgramFrameRingBuffer.hpp"

#include <algorithm>
#include <new>

namespace esvb {

ProgramFrameRingBuffer::ProgramFrameRingBuffer(std::size_t capacity)
    : capacity_(std::max<std::size_t>(capacity, 1)) {
    slots_ = new FrameDescriptor[capacity_];
}

void ProgramFrameRingBuffer::push(FrameDescriptor descriptor) {
    slots_[writeIndex_] = descriptor;
    writeIndex_ = (writeIndex_ + 1) % capacity_;
    count_ = std::min(count_ + 1, capacity_);
}

bool ProgramFrameRingBuffer::latest(FrameDescriptor &out) const {
    if (count_ == 0) {
        return false;
    }
    const std::size_t latestIndex = (writeIndex_ + capacity_ - 1) % capacity_;
    out = slots_[latestIndex];
    return true;
}

} // namespace esvb
