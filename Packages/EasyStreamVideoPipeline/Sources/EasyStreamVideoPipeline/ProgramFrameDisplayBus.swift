import CoreVideo
import EasyStreamCore
import EasyStreamVideoBusNative
import Foundation
import simd
import WebRTC

/// Thread-safe frame bus — native C++ ring buffer (CVPixelBuffer retain) + Swift conversion queue.
///
/// NV12/CVPixelBuffer frames push synchronously on the WebRTC thread so cuts see the latest hold.
/// I420 software decode converts on `processingQueue` before pushing.
public final class ProgramFrameDisplayBus: @unchecked Sendable {
    public static let shared = ProgramFrameDisplayBus()

    public struct Sample: Sendable {
        public let pixelBuffer: CVPixelBuffer
        public let contentSize: SIMD2<Float>
        public let isNV12: Bool
        public let sequence: UInt64
    }

    public var onDisplayRefreshRequested: (@Sendable () -> Void)?

    private let processingQueue = DispatchQueue(
        label: "com.easystream.program-frame-bus.processing",
        qos: .userInitiated
    )

    private let rampGraceLock = NSLock()
    /// After a preview-tier promote, accept live sub-HD frames on the on-air lane until HD lands.
    private var subHDOnAirGraceDeadline: DispatchTime?

    private init() {}

    // MARK: - Ingest

    public func enqueue(_ frame: RTCVideoFrame, lane: ProgramFrameBusSlot) {
        if let cvBuffer = frame.buffer as? RTCCVPixelBuffer {
            publish(pixelBuffer: cvBuffer.pixelBuffer, lane: lane)
            return
        }

        processingQueue.async { [weak self] in
            guard let self else { return }
            if let pixelBuffer = WebRTCVideoFramePixelBuffer.extract(from: frame) {
                self.publish(pixelBuffer: pixelBuffer, lane: lane)
            }
        }
    }

    public func publish(pixelBuffer: CVPixelBuffer, lane: ProgramFrameBusSlot) {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        if lane == .programOnAir, !allowsOnAirPublish(width: width, height: height) {
            ProgramBusTrace.eventThrottled(
                "bus-drop-onair-subhd",
                intervalMs: 500,
                "bus drop on-air sub-threshold frame \(width)x\(height)"
            )
            return
        }

        let widthF = Float(width)
        let heightF = Float(height)
        let format = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let isNV12 = format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            || format == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange

        NativeProgramFrameBus.push(lane: lane, pixelBuffer: pixelBuffer, isNV12: isNV12)

        if let sample = displaySample(for: lane) {
            ProgramBusTrace.lanePublish(
                lane: lane,
                width: Int(widthF),
                height: Int(heightF),
                sequence: sample.sequence
            )
        }

        ProgramFrameTelemetryRegistry.live.recordFrame(
            busSlot: lane,
            width: Int(widthF),
            height: Int(heightF)
        )
    }

    public func publish(_ sample: Sample, lane: ProgramFrameBusSlot) {
        publish(pixelBuffer: sample.pixelBuffer, lane: lane)
    }

    // MARK: - Display

    public func displaySample(for lane: ProgramFrameBusSlot) -> Sample? {
        guard let native = NativeProgramFrameBus.copyDisplayFrame(for: lane) else { return nil }
        return Sample(
            pixelBuffer: native.pixelBuffer,
            contentSize: native.contentSize,
            isNV12: native.isNV12,
            sequence: native.sequence
        )
    }

    /// Waits briefly for the incoming lane to hold a decodable frame before a cut promote.
    public func waitForIncomingDisplaySample(maxAttempts: Int = 6, intervalMs: UInt64 = 4) async -> Sample? {
        for attempt in 0..<maxAttempts {
            if let sample = displaySample(for: .programIncoming) {
                return sample
            }
            if attempt + 1 < maxAttempts {
                try? await Task.sleep(for: .milliseconds(intervalMs))
            }
        }
        return displaySample(for: .programIncoming)
    }

    public func incomingMeetsProgramDisplayThreshold() -> Bool {
        guard let incoming = displaySample(for: .programIncoming) else { return false }
        return ProgramFrameQualityGate.acceptsOnAirFrame(
            width: Int(incoming.contentSize.x),
            height: Int(incoming.contentSize.y)
        )
    }

    /// Waits briefly for incoming lane to reach program display threshold (prewarmed preview encode).
    public func waitForIncomingProgramThreshold(maxAttempts: Int = 45, intervalMs: UInt64 = 16) async -> Bool {
        for attempt in 0..<maxAttempts {
            if incomingMeetsProgramDisplayThreshold() {
                return true
            }
            if attempt + 1 < maxAttempts {
                try? await Task.sleep(for: .milliseconds(intervalMs))
            }
        }
        return incomingMeetsProgramDisplayThreshold()
    }

    public func promoteIncomingToOnAir(allowPreviewTier: Bool = false) {
        let incoming = displaySample(for: .programIncoming)
        guard let incoming else {
            ProgramBusTrace.event("bus promote skipped no incoming frame")
            return
        }
        if !allowPreviewTier,
           !ProgramFrameQualityGate.acceptsOnAirFrame(
               width: Int(incoming.contentSize.x),
               height: Int(incoming.contentSize.y)
           ) {
            ProgramBusTrace.event(
                "bus promote skipped incoming=\(sizeLabel(incoming)) below program threshold"
            )
            return
        }
        if allowPreviewTier {
            beginSubHDOnAirGracePeriod()
        }
        let programBefore = displaySample(for: .programOnAir)
        NativeProgramFrameBus.promoteIncomingToOnAir()
        let programAfter = displaySample(for: .programOnAir)
        ProgramBusTrace.event(
            "bus promote incoming=\(sizeLabel(incoming)) previewTier=\(allowPreviewTier) programBefore=\(sizeLabel(programBefore)) programAfter=\(sizeLabel(programAfter))"
        )
    }

    /// Keeps the on-air lane live with sub-HD frames while the camera encoder ramps to program tier.
    public func beginSubHDOnAirGracePeriod(milliseconds: Int = 3_000) {
        rampGraceLock.lock()
        subHDOnAirGraceDeadline = .now() + .milliseconds(milliseconds)
        rampGraceLock.unlock()
        ProgramBusTrace.event("bus on-air sub-HD grace \(milliseconds)ms")
    }

    private func allowsOnAirPublish(width: Int, height: Int) -> Bool {
        if ProgramFrameQualityGate.acceptsOnAirFrame(width: width, height: height) {
            endSubHDOnAirGraceIfActive(reason: "HD frame")
            return true
        }
        rampGraceLock.lock()
        defer { rampGraceLock.unlock() }
        guard let deadline = subHDOnAirGraceDeadline else { return false }
        return DispatchTime.now() < deadline
    }

    private func endSubHDOnAirGraceIfActive(reason: String) {
        rampGraceLock.lock()
        defer { rampGraceLock.unlock() }
        guard subHDOnAirGraceDeadline != nil else { return }
        subHDOnAirGraceDeadline = nil
        ProgramBusTrace.event("bus on-air sub-HD grace ended (\(reason))")
    }

    private func sizeLabel(_ sample: Sample?) -> String {
        guard let sample else { return "nil" }
        return "\(Int(sample.contentSize.x))x\(Int(sample.contentSize.y)) seq=\(sample.sequence)"
    }

    public func clearTransitionLanes() {
        NativeProgramFrameBus.clearTransitionLanes()
    }

    public func clearAllLanes() {
        NativeProgramFrameBus.clearAll()
    }

    public func clearOnAirLane() {
        NativeProgramFrameBus.clearOnAirLane()
    }
}
