import SwiftUI
import EasyStreamCore
import WebRTC

public struct PreviewMonitorCamera: Identifiable, Equatable {
    public let id: CameraSourceID
    public let displayName: String
    public let track: RTCVideoTrack?
    public let isConnected: Bool
    public let isMuted: Bool
    public let sourceIndex: Int
    public let platform: DevicePlatform
    public let link: CameraLinkKind
    public let portLabel: String
    public let isSimulated: Bool

    public init(
        id: CameraSourceID,
        displayName: String,
        track: RTCVideoTrack?,
        isConnected: Bool,
        isMuted: Bool,
        sourceIndex: Int,
        platform: DevicePlatform = .unknown,
        link: CameraLinkKind = .wifi,
        portLabel: String = "",
        isSimulated: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.track = track
        self.isConnected = isConnected
        self.isMuted = isMuted
        self.sourceIndex = sourceIndex
        self.platform = platform
        self.link = link
        self.portLabel = portLabel
        self.isSimulated = isSimulated
    }
}
