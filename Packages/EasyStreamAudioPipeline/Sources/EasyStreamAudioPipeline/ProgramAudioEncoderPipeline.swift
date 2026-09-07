import Foundation
import EasyStreamCore

/// Encodes tapped program playout PCM into AAC packets.
public actor ProgramAudioEncoderPipeline {
    public enum Event: Sendable {
        case started
        case stopped
        case sample(EncodedAudioSample)
        case failed(String)
    }

    private let encoder = AACAudioEncoder()
    private var sampleTask: Task<Void, Never>?
    private var eventContinuation: AsyncStream<Event>.Continuation?
    private var isActive = false

    public init() {}

    public func events() -> AsyncStream<Event> {
        AsyncStream { continuation in
            eventContinuation = continuation
        }
    }

    public func stats() async -> AudioEncoderStats {
        await encoder.currentStats()
    }

    public func start(configuration: AudioEncoderConfiguration = .broadcastAAC) async {
        if isActive {
            return
        }
        await stopInternal(emitStopped: false)

        do {
            try await encoder.start(configuration: configuration)
        } catch {
            await publish(.failed(error.localizedDescription))
            return
        }

        sampleTask = Task { [weak self] in
            guard let self else { return }
            for await sample in await self.encoder.encodedSamples() {
                guard !Task.isCancelled else { break }
                await self.publish(.sample(sample))
            }
        }

        ProgramAudioTapRegistry.setHandler { [weak self] pcm, sampleRate, channels, frames in
            Task { await self?.handlePCM(pcm, sampleRate: sampleRate, channels: channels, frames: frames) }
        }

        isActive = true
        await publish(.started)
        EasyStreamLog.audio.info("Program AAC pipeline started")
    }

    public func stop() async {
        await stopInternal(emitStopped: true)
    }

    private func handlePCM(_ pcm: Data, sampleRate: Double, channels: UInt32, frames: UInt32) async {
        guard isActive else { return }
        do {
            try await encoder.encode(pcm: pcm, sampleRate: sampleRate, channels: channels, frames: frames)
        } catch {
            await publish(.failed(error.localizedDescription))
        }
    }

    private func stopInternal(emitStopped: Bool) async {
        isActive = false
        ProgramAudioTapRegistry.setHandler(nil)
        sampleTask?.cancel()
        sampleTask = nil
        await encoder.stop()

        if emitStopped {
            await publish(.stopped)
        }
    }

    private func publish(_ event: Event) {
        eventContinuation?.yield(event)
    }
}
