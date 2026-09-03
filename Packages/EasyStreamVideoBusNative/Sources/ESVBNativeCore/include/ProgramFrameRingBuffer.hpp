#pragma once

#include <cstddef>
#include <cstdint>

namespace esvb {

/// Fixed-capacity ring buffer for NV12/I420 frame metadata (Phase C++ core).
/// Full pixel upload to Metal will replace Swift-side duplication in later phases.
class ProgramFrameRingBuffer {
public:
    struct FrameDescriptor {
        std::uint64_t sequence = 0;
        std::uint32_t width = 0;
        std::uint32_t height = 0;
        double presentationTimeSeconds = 0;
    };

    explicit ProgramFrameRingBuffer(std::size_t capacity);

    void push(FrameDescriptor descriptor);
    bool latest(FrameDescriptor &out) const;
    std::size_t capacity() const noexcept { return capacity_; }

private:
    std::size_t capacity_;
    std::size_t writeIndex_ = 0;
    std::size_t count_ = 0;
    FrameDescriptor *slots_ = nullptr;
};

} // namespace esvb
