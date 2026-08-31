import Foundation

public enum SignalingMessage: Sendable, Equatable {
    case hello(deviceID: UUID, displayName: String, role: String)
    case offer(sessionID: UUID, sdp: String)
    case answer(sessionID: UUID, sdp: String)
    case ice(sessionID: UUID, candidate: String, sdpMid: String?, sdpMLineIndex: Int32?)
    case control(RemoteCameraCommand)
    case settingsState(deviceID: UUID, settings: RemoteCameraSettings)
}

extension SignalingMessage: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case deviceID
        case displayName
        case role
        case sessionID
        case sdp
        case candidate
        case sdpMid
        case sdpMLineIndex
        case command
        case settings
    }

    private enum MessageType: String, Codable {
        case hello, offer, answer, ice, control, settingsState
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)
        switch type {
        case .hello:
            self = .hello(
                deviceID: try container.decode(UUID.self, forKey: .deviceID),
                displayName: try container.decode(String.self, forKey: .displayName),
                role: try container.decode(String.self, forKey: .role)
            )
        case .offer:
            self = .offer(
                sessionID: try container.decode(UUID.self, forKey: .sessionID),
                sdp: try container.decode(String.self, forKey: .sdp)
            )
        case .answer:
            self = .answer(
                sessionID: try container.decode(UUID.self, forKey: .sessionID),
                sdp: try container.decode(String.self, forKey: .sdp)
            )
        case .ice:
            self = .ice(
                sessionID: try container.decode(UUID.self, forKey: .sessionID),
                candidate: try container.decode(String.self, forKey: .candidate),
                sdpMid: try container.decodeIfPresent(String.self, forKey: .sdpMid),
                sdpMLineIndex: try container.decodeIfPresent(Int32.self, forKey: .sdpMLineIndex)
            )
        case .control:
            self = .control(try container.decode(RemoteCameraCommand.self, forKey: .command))
        case .settingsState:
            self = .settingsState(
                deviceID: try container.decode(UUID.self, forKey: .deviceID),
                settings: try container.decode(RemoteCameraSettings.self, forKey: .settings)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .hello(let deviceID, let displayName, let role):
            try container.encode(MessageType.hello, forKey: .type)
            try container.encode(deviceID, forKey: .deviceID)
            try container.encode(displayName, forKey: .displayName)
            try container.encode(role, forKey: .role)
        case .offer(let sessionID, let sdp):
            try container.encode(MessageType.offer, forKey: .type)
            try container.encode(sessionID, forKey: .sessionID)
            try container.encode(sdp, forKey: .sdp)
        case .answer(let sessionID, let sdp):
            try container.encode(MessageType.answer, forKey: .type)
            try container.encode(sessionID, forKey: .sessionID)
            try container.encode(sdp, forKey: .sdp)
        case .ice(let sessionID, let candidate, let sdpMid, let sdpMLineIndex):
            try container.encode(MessageType.ice, forKey: .type)
            try container.encode(sessionID, forKey: .sessionID)
            try container.encode(candidate, forKey: .candidate)
            try container.encodeIfPresent(sdpMid, forKey: .sdpMid)
            try container.encodeIfPresent(sdpMLineIndex, forKey: .sdpMLineIndex)
        case .control(let command):
            try container.encode(MessageType.control, forKey: .type)
            try container.encode(command, forKey: .command)
        case .settingsState(let deviceID, let settings):
            try container.encode(MessageType.settingsState, forKey: .type)
            try container.encode(deviceID, forKey: .deviceID)
            try container.encode(settings, forKey: .settings)
        }
    }
}

public enum StreamConnectionState: String, Sendable, Equatable {
    case idle
    case connecting
    case signaling
    case connected
    case disconnected
    case failed
}

public struct RemoteStreamSession: Sendable, Identifiable, Equatable {
    public let id: UUID
    public let remoteDeviceID: UUID
    public let remoteDisplayName: String
    public var connectionState: StreamConnectionState

    public init(
        id: UUID = UUID(),
        remoteDeviceID: UUID,
        remoteDisplayName: String,
        connectionState: StreamConnectionState
    ) {
        self.id = id
        self.remoteDeviceID = remoteDeviceID
        self.remoteDisplayName = remoteDisplayName
        self.connectionState = connectionState
    }
}
