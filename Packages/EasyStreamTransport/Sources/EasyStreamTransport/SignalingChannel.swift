import Foundation
import Network
import EasyStreamCore

/// Bidirectional newline-delimited JSON signaling over a TCP `NWConnection`.
public actor SignalingChannel {
    public enum Event: Sendable {
        case connected
        case message(SignalingMessage)
        case disconnected
        case failed(String)
    }

    public let id = UUID()
    private let connection: NWConnection
    private var receiveBuffer = Data()
    private var isRunning = false
    private var continuation: AsyncStream<Event>.Continuation?

    public init(connection: NWConnection) {
        self.connection = connection
    }

    public func events() -> AsyncStream<Event> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.stop() }
            }
            self.start()
        }
    }

    public func send(_ message: SignalingMessage) async throws {
        let data = try SignalingCodec.encode(message)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            })
        }
    }

    public func stop() {
        isRunning = false
        connection.cancel()
        continuation?.finish()
        continuation = nil
    }

    private func start() {
        guard !isRunning else { return }
        isRunning = true

        connection.stateUpdateHandler = { [weak self] state in
            Task { await self?.handleState(state) }
        }

        connection.start(queue: .global(qos: .userInitiated))
    }

    private func handleState(_ state: NWConnection.State) {
        switch state {
        case .ready:
            emit(.connected)
            receiveNextChunk()
        case .failed(let error):
            emit(.failed(error.localizedDescription))
            stop()
        case .cancelled:
            emit(.disconnected)
        default:
            break
        }
    }

    private func receiveNextChunk() {
        guard isRunning else { return }

        connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { [weak self] content, _, isComplete, error in
            Task { await self?.handleReceive(content: content, isComplete: isComplete, error: error) }
        }
    }

    private func handleReceive(content: Data?, isComplete: Bool, error: NWError?) {
        if let error {
            emit(.failed(error.localizedDescription))
            stop()
            return
        }

        if let content, !content.isEmpty {
            receiveBuffer.append(content)
            let messages = SignalingCodec.decodeMessages(from: &receiveBuffer)
            for message in messages {
                emit(.message(message))
            }
        }

        if isComplete {
            emit(.disconnected)
            stop()
            return
        }

        receiveNextChunk()
    }

    private func emit(_ event: Event) {
        continuation?.yield(event)
    }
}

enum SignalingCodec {
    static func encode(_ message: SignalingMessage) throws -> Data {
        let encoder = JSONEncoder()
        var payload = try encoder.encode(message)
        payload.append(0x0A)
        return payload
    }

    static func decodeMessages(from buffer: inout Data) -> [SignalingMessage] {
        var messages: [SignalingMessage] = []
        let decoder = JSONDecoder()

        while let newlineIndex = buffer.firstIndex(of: 0x0A) {
            let line = buffer[..<newlineIndex]
            buffer.removeSubrange(0...newlineIndex)

            guard !line.isEmpty else { continue }
            if let message = try? decoder.decode(SignalingMessage.self, from: Data(line)) {
                messages.append(message)
            }
        }

        return messages
    }
}
