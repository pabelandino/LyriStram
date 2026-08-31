import Foundation

enum AMF0 {
    static let number: UInt8 = 0x00
    static let boolean: UInt8 = 0x01
    static let string: UInt8 = 0x02
    static let object: UInt8 = 0x03
    static let null: UInt8 = 0x05
    static let objectEnd: UInt8 = 0x09

    static func encodeString(_ value: String) -> Data {
        let utf8 = Data(value.utf8)
        var data = Data([string])
        data.append(contentsOf: encodeUTF8StringBody(utf8))
        return data
    }

    static func encodeNumber(_ value: Double) -> Data {
        var data = Data([number])
        var bits = value.bitPattern.bigEndian
        withUnsafeBytes(of: &bits) { data.append(contentsOf: $0) }
        return data
    }

    static func encodeNull() -> Data {
        Data([null])
    }

    static func encodeObject(_ fields: [(String, Data)]) -> Data {
        var data = Data([object])
        for (key, value) in fields {
            data.append(contentsOf: encodeUTF8StringBody(Data(key.utf8)))
            data.append(value)
        }
        data.append(contentsOf: encodeUTF8StringBody(Data()))
        data.append(objectEnd)
        return data
    }

    static func encodeCommand(name: String, transactionID: Double, commandObject: Data?, args: [Data]) -> Data {
        var payload = encodeString(name)
        payload.append(encodeNumber(transactionID))
        if let commandObject {
            payload.append(commandObject)
        } else {
            payload.append(encodeNull())
        }
        for arg in args {
            payload.append(arg)
        }
        return payload
    }

    private static func encodeUTF8StringBody(_ utf8: Data) -> Data {
        if utf8.count > 65535 {
            var data = Data([0x00, 0x00])
            var length = UInt32(utf8.count).bigEndian
            withUnsafeBytes(of: &length) { data.append(contentsOf: $0) }
            data.append(utf8)
            return data
        }
        var length = UInt16(utf8.count).bigEndian
        var data = Data()
        withUnsafeBytes(of: &length) { data.append(contentsOf: $0) }
        data.append(utf8)
        return data
    }
}

enum RTMPMessageType {
    static let audio: UInt8 = 8
    static let video: UInt8 = 9
    static let amf0Command: UInt8 = 20
}

struct RTMPChunk {
    let messageType: UInt8
    let payload: Data
}

enum RTMPChunkReader {
    static func nextChunk(from buffer: inout Data, chunkSize: Int) -> RTMPChunk? {
        guard !buffer.isEmpty else { return nil }

        var index = buffer.startIndex
        let first = buffer[index]
        let fmt = first >> 6
        var csID = Int(first & 0x3F)
        index = buffer.index(after: index)

        if csID == 0 {
            guard index < buffer.endIndex else { return nil }
            csID = 64 + Int(buffer[index])
            index = buffer.index(after: index)
        } else if csID == 1 {
            guard buffer.distance(from: index, to: buffer.endIndex) >= 2 else { return nil }
            let second = Int(buffer[index])
            let third = Int(buffer[buffer.index(after: index)])
            csID = 64 + (second << 8) + third
            index = buffer.index(index, offsetBy: 2)
        }

        var messageLength: UInt32 = 0
        var messageType: UInt8 = 0

        switch fmt {
        case 0:
            guard buffer.distance(from: index, to: buffer.endIndex) >= 11 else { return nil }
            index = buffer.index(index, offsetBy: 3) // timestamp
            messageLength = readUInt24(buffer, at: index)
            index = buffer.index(index, offsetBy: 3)
            messageType = buffer[index]
            index = buffer.index(after: index)
            index = buffer.index(index, offsetBy: 4) // stream id
        case 1:
            guard buffer.distance(from: index, to: buffer.endIndex) >= 7 else { return nil }
            index = buffer.index(index, offsetBy: 3)
            messageLength = readUInt24(buffer, at: index)
            index = buffer.index(index, offsetBy: 3)
            messageType = buffer[index]
            index = buffer.index(after: index)
        default:
            return nil
        }

        let payloadLength = Int(messageLength)
        guard buffer.distance(from: index, to: buffer.endIndex) >= payloadLength else { return nil }

        let payload = Data(buffer[index..<buffer.index(index, offsetBy: payloadLength)])
        index = buffer.index(index, offsetBy: payloadLength)
        buffer.removeSubrange(buffer.startIndex..<index)

        return RTMPChunk(messageType: messageType, payload: payload)
    }

    private static func readUInt24(_ data: Data, at index: Data.Index) -> UInt32 {
        let b0 = UInt32(data[index])
        let b1 = UInt32(data[data.index(after: index)])
        let b2 = UInt32(data[data.index(index, offsetBy: 2)])
        return (b0 << 16) | (b1 << 8) | b2
    }
}

enum RTMPChunkWriter {
    static func write(chunkStreamID: Int, messageType: UInt8, streamID: UInt32, timestamp: UInt32, payload: Data, chunkSize: Int) -> Data {
        var result = Data()
        var offset = 0
        var firstChunk = true

        while offset < payload.count {
            let size = min(chunkSize, payload.count - offset)
            let slice = payload.subdata(in: offset..<(offset + size))

            if firstChunk {
                result.append(basicHeader(chunkStreamID: chunkStreamID, fmt: 0))
                result.append(messageHeader0(timestamp: timestamp, length: UInt32(payload.count), type: messageType, streamID: streamID))
                firstChunk = false
            } else {
                result.append(basicHeader(chunkStreamID: chunkStreamID, fmt: 3))
            }

            result.append(slice)
            offset += size
        }

        return result
    }

    private static func basicHeader(chunkStreamID: Int, fmt: Int) -> Data {
        let fmtBits = (fmt & 0x03) << 6
        if chunkStreamID < 64 {
            return Data([UInt8(fmtBits | (chunkStreamID & 0x3F))])
        } else if chunkStreamID < 320 {
            return Data([UInt8(fmtBits), UInt8(chunkStreamID - 64)])
        } else {
            let adjusted = chunkStreamID - 64
            return Data([
                UInt8(fmtBits | 1),
                UInt8(adjusted & 0xFF),
                UInt8((adjusted >> 8) & 0xFF),
            ])
        }
    }

    private static func messageHeader0(timestamp: UInt32, length: UInt32, type: UInt8, streamID: UInt32) -> Data {
        var data = Data()
        data.append(contentsOf: encodeUInt24(timestamp))
        data.append(contentsOf: encodeUInt24(length))
        data.append(type)
        var leStream = streamID.littleEndian
        withUnsafeBytes(of: &leStream) { data.append(contentsOf: $0) }
        return data
    }

    private static func encodeUInt24(_ value: UInt32) -> [UInt8] {
        [
            UInt8((value >> 16) & 0xFF),
            UInt8((value >> 8) & 0xFF),
            UInt8(value & 0xFF),
        ]
    }
}

enum RTMPStreamError: Error, Sendable, LocalizedError {
    case connectionFailed(String)
    case handshakeFailed
    case commandFailed(String)
    case notConnected
    case sendFailed

    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message): message
        case .handshakeFailed: "RTMP handshake failed"
        case .commandFailed(let message): message
        case .notConnected: "RTMP not connected"
        case .sendFailed: "Failed to send RTMP data"
        }
    }
}
