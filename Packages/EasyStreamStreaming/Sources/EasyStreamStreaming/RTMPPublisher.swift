import Foundation
import Network
import EasyStreamCore

/// Low-level RTMP/RTMPS session for publishing FLV audio/video payloads.
public actor RTMPPublisher {
    private var connection: NWConnection?
    private var receiveBuffer = Data()
    private var chunkSize = 4096
    private var streamID: UInt32 = 1
    private var nextTransactionID: Double = 1
    private var isConnected = false
    private var bytesSent = 0

    public init() {}

    public func currentBytesSent() -> Int {
        bytesSent
    }

    public func connect(_ destination: StreamDestination) async throws {
        await disconnect()

        let parsed = try destination.parsed()
        let host = NWEndpoint.Host(parsed.host)
        let port = NWEndpoint.Port(rawValue: parsed.port) ?? (parsed.useTLS ? 443 : 1935)

        let tcp = NWProtocolTCP.Options()
        tcp.enableKeepalive = true

        let parameters: NWParameters
        if parsed.useTLS {
            let tls = NWProtocolTLS.Options()
            parameters = NWParameters(tls: tls, tcp: tcp)
        } else {
            parameters = NWParameters(tls: nil, tcp: tcp)
        }

        let conn = NWConnection(host: host, port: port, using: parameters)
        connection = conn

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            conn.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    conn.stateUpdateHandler = nil
                    continuation.resume()
                case .failed(let error):
                    conn.stateUpdateHandler = nil
                    continuation.resume(throwing: RTMPStreamError.connectionFailed(error.localizedDescription))
                case .cancelled:
                    conn.stateUpdateHandler = nil
                    continuation.resume(throwing: RTMPStreamError.connectionFailed("Connection cancelled"))
                default:
                    break
                }
            }
            conn.start(queue: .global(qos: .userInitiated))
        }

        try await performHandshake()
        try await performPublish(parsed: parsed)
        isConnected = true
        EasyStreamLog.rtmp.info("RTMP connected to \(parsed.host, privacy: .public)")
    }

    public func sendVideo(_ payload: Data, timestamp: UInt32) async throws {
        try await sendMedia(type: RTMPMessageType.video, payload: payload, timestamp: timestamp)
    }

    public func sendAudio(_ payload: Data, timestamp: UInt32) async throws {
        try await sendMedia(type: RTMPMessageType.audio, payload: payload, timestamp: timestamp)
    }

    public func disconnect() async {
        connection?.cancel()
        connection = nil
        receiveBuffer.removeAll()
        isConnected = false
    }

    private func performHandshake() async throws {
        var c0c1 = Data([0x03])
        c0c1.append(Data(repeating: 0, count: 4))
        c0c1.append(Data(repeating: 0, count: 4))
        c0c1.append(Data((0..<1528).map { _ in UInt8.random(in: 0...255) }))

        try await sendRaw(c0c1)

        let s0s1s2 = try await receiveExact(count: 1 + 1536 + 1536)
        guard s0s1s2.first == 0x03 else { throw RTMPStreamError.handshakeFailed }

        let s1 = s0s1s2.subdata(in: 1..<(1 + 1536))
        var c2 = Data()
        c2.append(s1)
        c2.append(Data(repeating: 0, count: 1536))
        try await sendRaw(c2)
    }

    private func performPublish(parsed: ParsedStreamDestination) async throws {
        let app = parsed.appName
        let streamName = parsed.streamName
        let tcURL = "\(parsed.useTLS ? "rtmps" : "rtmp")://\(parsed.host):\(parsed.port)/\(app)"

        let connectObject = AMF0.encodeObject([
            ("app", AMF0.encodeString(app)),
            ("type", AMF0.encodeString("nonprivate")),
            ("flashVer", AMF0.encodeString("FMLE/3.0 (compatible; EasyStream)")),
            ("tcUrl", AMF0.encodeString(tcURL)),
        ])

        try await sendCommand(
            name: "connect",
            transactionID: nextTransactionID,
            commandObject: connectObject,
            args: [],
            streamID: 0
        )
        nextTransactionID += 1
        _ = try await waitForCommandResult(timeoutSeconds: 5)

        try await sendCommand(name: "releaseStream", transactionID: nextTransactionID, commandObject: nil, args: [AMF0.encodeString(streamName)], streamID: 0)
        nextTransactionID += 1
        _ = try await waitForCommandResult(timeoutSeconds: 5)

        try await sendCommand(name: "FCPublish", transactionID: nextTransactionID, commandObject: nil, args: [AMF0.encodeString(streamName)], streamID: 0)
        nextTransactionID += 1
        _ = try await waitForCommandResult(timeoutSeconds: 5)

        try await sendCommand(name: "createStream", transactionID: nextTransactionID, commandObject: nil, args: [], streamID: 0)
        _ = try await waitForCommandResult(timeoutSeconds: 5)

        try await sendCommand(
            name: "publish",
            transactionID: nextTransactionID,
            commandObject: nil,
            args: [AMF0.encodeString(streamName), AMF0.encodeString("live")],
            streamID: streamID
        )
        nextTransactionID += 1
        _ = try await waitForCommandResult(timeoutSeconds: 5)
    }

    private func sendCommand(
        name: String,
        transactionID: Double,
        commandObject: Data?,
        args: [Data],
        streamID: UInt32
    ) async throws {
        let payload = AMF0.encodeCommand(
            name: name,
            transactionID: transactionID,
            commandObject: commandObject,
            args: args
        )
        let packet = RTMPChunkWriter.write(
            chunkStreamID: 3,
            messageType: RTMPMessageType.amf0Command,
            streamID: streamID,
            timestamp: 0,
            payload: payload,
            chunkSize: chunkSize
        )
        try await sendRaw(packet)
    }

    private func sendMedia(type: UInt8, payload: Data, timestamp: UInt32) async throws {
        guard isConnected else { throw RTMPStreamError.notConnected }
        let csID = type == RTMPMessageType.video ? 6 : 4
        let packet = RTMPChunkWriter.write(
            chunkStreamID: csID,
            messageType: type,
            streamID: streamID,
            timestamp: timestamp,
            payload: payload,
            chunkSize: chunkSize
        )
        try await sendRaw(packet)
    }

    private func sendRaw(_ data: Data) async throws {
        guard let connection else { throw RTMPStreamError.notConnected }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if error != nil {
                    continuation.resume(throwing: RTMPStreamError.sendFailed)
                } else {
                    continuation.resume()
                }
            })
        }
        bytesSent += data.count
        startReceiveLoopIfNeeded()
    }

    private func startReceiveLoopIfNeeded() {
        guard let connection else { return }
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, error in
            guard let self else { return }
            Task {
                if let data, !data.isEmpty {
                    await self.appendReceiveBuffer(data)
                }
                if error == nil {
                    await self.startReceiveLoopIfNeeded()
                }
            }
        }
    }

    private func appendReceiveBuffer(_ data: Data) {
        receiveBuffer.append(data)
    }

    private func waitForCommandResult(timeoutSeconds: Double) async throws -> Double? {
        let deadline = Date().addingTimeInterval(timeoutSeconds)
        while Date() < deadline {
            if parseNextCommandResult() {
                return 1
            }
            try await Task.sleep(for: .milliseconds(20))
            if let data = try? await receiveAvailable() {
                receiveBuffer.append(data)
            }
        }
        return nil
    }

    @discardableResult
    private func parseNextCommandResult() -> Bool {
        while let chunk = RTMPChunkReader.nextChunk(from: &receiveBuffer, chunkSize: chunkSize) {
            guard chunk.messageType == RTMPMessageType.amf0Command else { continue }
            if let commandName = readAMF0String(from: chunk.payload, at: 0) {
                if commandName == "_result" || commandName == "onStatus" {
                    return true
                }
            }
        }
        return false
    }

    private func readAMF0String(from data: Data, at offset: Int) -> String? {
        guard data.count > offset + 3, data[offset] == 0x02 else { return nil }
        let length = Int(data[offset + 1]) << 8 | Int(data[offset + 2])
        let start = offset + 3
        guard data.count >= start + length else { return nil }
        return String(data: data.subdata(in: start..<(start + length)), encoding: .utf8)
    }

    private func receiveExact(count: Int) async throws -> Data {
        let deadline = Date().addingTimeInterval(10)
        while receiveBuffer.count < count {
            if Date() > deadline { throw RTMPStreamError.handshakeFailed }
            if let data = try await receiveAvailable() {
                receiveBuffer.append(data)
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        let chunk = receiveBuffer.prefix(count)
        receiveBuffer.removeFirst(count)
        return Data(chunk)
    }

    private func receiveAvailable() async throws -> Data? {
        guard let connection else { return nil }
        return try await withCheckedThrowingContinuation { continuation in
            connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, _, error in
                if let error {
                    continuation.resume(throwing: RTMPStreamError.connectionFailed(error.localizedDescription))
                } else {
                    continuation.resume(returning: data)
                }
            }
        }
    }
}
