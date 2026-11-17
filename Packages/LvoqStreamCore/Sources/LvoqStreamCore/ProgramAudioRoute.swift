import Foundation

public enum ProgramAudioLatencyMode: String, Codable, Sendable {
    /// Delay a local audio interface by the measured video arrival time.
    case picture
    /// Operator-chosen trim, in milliseconds.
    case manual
}

public enum ProgramAudioOutputChoice: String, Codable, Sendable {
    case system
    case speaker
}

public struct ProgramAudioLocalInput: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

/// Audio-thread flags. The monitor writes them; playout and the video tap read them.
public final class ProgramAudioRouteFlags: @unchecked Sendable {
    public static let shared = ProgramAudioRouteFlags()

    private let lock = NSLock()
    private var delayMs: Double = 0
    private var localCapture = false
    private var feedLiveVideo = false

    public func set(delayMs: Double, localCapture: Bool, feedLiveVideo: Bool) {
        lock.lock()
        self.delayMs = max(0, delayMs)
        self.localCapture = localCapture
        self.feedLiveVideo = feedLiveVideo
        lock.unlock()
    }

    public func snapshot() -> (delayMs: Double, localCapture: Bool, feedLiveVideo: Bool) {
        lock.lock()
        defer { lock.unlock() }
        return (delayMs, localCapture, feedLiveVideo)
    }
}

/// Peak of the program audio that is about to play and be encoded.
public enum ProgramAudioLevelBus {
    private final class Storage: @unchecked Sendable {
        let lock = NSLock()
        var peak: Float = 0
    }

    private static let storage = Storage()

    public static func note(pcm: Data) {
        let sampleCount = pcm.count / MemoryLayout<Int16>.size
        guard sampleCount > 0 else { return }
        var maxSample: Int32 = 0
        pcm.withUnsafeBytes { raw in
            let samples = raw.bindMemory(to: Int16.self)
            for sample in samples {
                maxSample = max(maxSample, abs(Int32(sample)))
            }
        }
        let level = min(1, Float(maxSample) / Float(Int16.max))
        storage.lock.lock()
        storage.peak = max(storage.peak * 0.82, level)
        storage.lock.unlock()
    }

    public static func current() -> Float {
        storage.lock.lock()
        let value = storage.peak
        storage.peak *= 0.9
        storage.lock.unlock()
        return value
    }
}

/// Sample queue that holds program audio for a short lip-sync trim.
public final class ProgramAudioDelayBuffer: @unchecked Sendable {
    public static let shared = ProgramAudioDelayBuffer()

    private let lock = NSLock()
    private var samples: [Int16] = []
    private var delayCount = 0
    private let capacity = 48_000 * 2 * 2

    public func setDelay(milliseconds: Double, sampleRate: Double, channels: UInt32) {
        let frames = Int((max(0, milliseconds) / 1000) * sampleRate)
        lock.lock()
        delayCount = frames * Int(max(channels, 1))
        lock.unlock()
    }

    public func push(_ pcm: Data) {
        guard !pcm.isEmpty else { return }
        let incoming = pcm.withUnsafeBytes { Array($0.bindMemory(to: Int16.self)) }
        lock.lock()
        samples.append(contentsOf: incoming)
        if samples.count > capacity {
            samples.removeFirst(samples.count - capacity)
        }
        lock.unlock()
    }

    /// Pulls `byteCount` delayed bytes. Returns silence until the delay has filled.
    public func pull(byteCount: Int) -> Data {
        let count = byteCount / MemoryLayout<Int16>.size
        guard count > 0 else { return Data() }
        lock.lock()
        defer { lock.unlock() }
        guard samples.count >= count + delayCount else {
            return Data(count: byteCount)
        }
        let start = samples.count - count - delayCount
        let slice = samples[start..<(start + count)]
        return slice.withUnsafeBufferPointer { Data(buffer: $0) }
    }

    public func reset() {
        lock.lock()
        samples.removeAll(keepingCapacity: true)
        lock.unlock()
    }
}
