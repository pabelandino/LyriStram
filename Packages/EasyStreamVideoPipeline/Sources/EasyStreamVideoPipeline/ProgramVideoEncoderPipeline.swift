import Foundation
import WebRTC
import EasyStreamCore
import CoreMedia

/// Captures Program Output frames from WebRTC and encodes them to H.264.
/// Only attached while network publishing — never during normal monitoring.
public actor ProgramVideoEncoderPipeline {
    public enum Event: Sendable {
        case started
        case stopped
        case sample(EncodedVideoSample)
        case failed(String)
    }

    private let encoder = H264VideoEncoder()
    private var frameSink: WebRTCProgramFrameSink?
    private weak var attachedTrack: RTCVideoTrack?
    private var sampleTask: Task<Void, Never>?
    private var eventContinuation: AsyncStream<Event>.Continuation?
    private var configuration = VideoEncoderConfiguration.broadcast1080p30
    /// Drops frames when encode cannot keep up — prevents unbounded Task pileup.
    private var isEncodingFrame = false

    public init() {}

    public func events() -> AsyncStream<Event> {
        AsyncStream { continuation in
            eventContinuation = continuation
        }
    }

    public func stats() async -> VideoEncoderStats {
        await encoder.currentStats()
    }

    public func start(
        programTrack: RTCVideoTrack?,
        configuration: VideoEncoderConfiguration = .broadcast1080p30
    ) async {
        await stopInternal(emitStopped: false)

        guard let programTrack else { return }

        self.configuration = configuration

        sampleTask = Task { [weak self] in
            guard let self else { return }
            for await sample in await self.encoder.encodedSamples() {
                guard !Task.isCancelled else { break }
                await self.publish(.sample(sample))
            }
        }

        do {
            try await encoder.start(configuration: configuration)
        } catch {
            await publish(.failed(error.localizedDescription))
            return
        }

        let sink = WebRTCProgramFrameSink()
        sink.onFrame = { [weak self] pixelBuffer, presentationTime in
            Task { await self?.handleFrame(pixelBuffer, presentationTime: presentationTime) }
        }

        programTrack.add(sink)
        frameSink = sink
        attachedTrack = programTrack

        await publish(.started)
        EasyStreamLog.encoder.info("Program H.264 pipeline attached to track")
    }

    public func stop() async {
        await stopInternal(emitStopped: true)
    }

    private func handleFrame(_ pixelBuffer: CVPixelBuffer, presentationTime: CMTime) async {
        guard !isEncodingFrame else { return }
        isEncodingFrame = true
        defer { isEncodingFrame = false }

        do {
            try await encoder.encode(pixelBuffer: pixelBuffer, presentationTime: presentationTime)
        } catch {
            await publish(.failed(error.localizedDescription))
        }
    }

    private func stopInternal(emitStopped: Bool) async {
        sampleTask?.cancel()
        sampleTask = nil
        isEncodingFrame = false

        if let attachedTrack, let frameSink {
            attachedTrack.remove(frameSink)
        }

        frameSink = nil
        attachedTrack = nil
        await encoder.stop()

        if emitStopped {
            await publish(.stopped)
        }
    }

    private func publish(_ event: Event) {
        eventContinuation?.yield(event)
    }
}
