import Foundation
import CoreMedia
import EasyStreamCore

/// Muxes encoded program media and publishes over RTMP/RTMPS.
public actor BroadcastStreamPublisher {
    public enum Event: Sendable {
        case stateChanged(StreamPublisherState)
        case failed(String)
    }

    private let rtmp = RTMPPublisher()
    private var eventContinuation: AsyncStream<Event>.Continuation?
    private var stats = StreamPublisherStats()
    private var timeOrigin: CMTime?
    private var sentAACSequenceHeader = false
    private var sentH264SequenceHeader = false

    public init() {}

    public func events() -> AsyncStream<Event> {
        AsyncStream { continuation in
            eventContinuation = continuation
        }
    }

    public func currentStats() -> StreamPublisherStats {
        stats
    }

    public func start(destination: StreamDestination) async {
        await stopInternal(emitStopped: false)

        guard destination.isConfigured else {
            await publishFailed("Configura la URL RTMP/RTMPS y el nombre del stream")
            return
        }

        updateState(.connecting)

        do {
            try await rtmp.connect(destination)
            timeOrigin = nil
            sentAACSequenceHeader = false
            sentH264SequenceHeader = false
            updateState(.publishing)
            EasyStreamLog.rtmp.info("Broadcast publisher live")
        } catch {
            await publishFailed(error.localizedDescription)
        }
    }

    public func stop() async {
        await stopInternal(emitStopped: true)
    }

    public func sendVideo(_ sample: EncodedVideoSample) async {
        guard stats.state == .publishing else { return }

        if timeOrigin == nil {
            timeOrigin = sample.presentationTime
        }
        guard let origin = timeOrigin else { return }

        do {
            if sample.isKeyframe,
               !sentH264SequenceHeader,
               let formatDescription = sample.formatDescription,
               let sequenceHeader = FLVBuilder.makeH264SequenceHeader(from: formatDescription) {
                let ts = FLVBuilder.timestampMs(from: sample.presentationTime, origin: origin)
                try await rtmp.sendVideo(sequenceHeader, timestamp: ts)
                sentH264SequenceHeader = true
            }

            guard sentH264SequenceHeader else { return }

            let payload = FLVBuilder.makeH264Frame(sample: sample)
            let ts = FLVBuilder.timestampMs(from: sample.presentationTime, origin: origin)
            try await rtmp.sendVideo(payload, timestamp: ts)

            stats.videoFramesSent += 1
            stats.bytesSent = await rtmp.currentBytesSent()
        } catch {
            await publishFailed(error.localizedDescription)
        }
    }

    public func sendAudio(_ sample: EncodedAudioSample) async {
        guard stats.state == .publishing else { return }

        if timeOrigin == nil {
            timeOrigin = sample.presentationTime
        }
        guard let origin = timeOrigin else { return }

        do {
            if !sentAACSequenceHeader {
                let sequenceHeader = FLVBuilder.makeAACSequenceHeader(sampleRate: 48_000, channels: 2)
                let ts = FLVBuilder.timestampMs(from: sample.presentationTime, origin: origin)
                try await rtmp.sendAudio(sequenceHeader, timestamp: ts)
                sentAACSequenceHeader = true
            }

            let payload = FLVBuilder.makeAACFrame(sample.data)
            let ts = FLVBuilder.timestampMs(from: sample.presentationTime, origin: origin)
            try await rtmp.sendAudio(payload, timestamp: ts)

            stats.audioPacketsSent += 1
            stats.bytesSent = await rtmp.currentBytesSent()
        } catch {
            await publishFailed(error.localizedDescription)
        }
    }

    private func stopInternal(emitStopped: Bool) async {
        await rtmp.disconnect()
        timeOrigin = nil
        sentAACSequenceHeader = false
        sentH264SequenceHeader = false
        stats = StreamPublisherStats(state: emitStopped ? .stopped : .idle)
        if emitStopped {
            eventContinuation?.yield(.stateChanged(.stopped))
        }
    }

    private func updateState(_ state: StreamPublisherState) {
        stats.state = state
        eventContinuation?.yield(.stateChanged(state))
    }

    private func publishFailed(_ message: String) async {
        stats.state = .failed
        eventContinuation?.yield(.failed(message))
        await rtmp.disconnect()
    }
}
