import Foundation
import Network

public enum DiscoveryConnectionState: String, Sendable, Equatable {
    case discovered
    case resolved
    case removed
}

/// A peer discovered via Bonjour on the local network.
public struct DiscoveredDevice: Sendable, Identifiable, Equatable, Hashable {
    public let id: UUID
    public let endpoint: NWEndpoint
    public let serviceType: BonjourServiceType
    public let displayName: String
    public let platform: DevicePlatform
    public let protocolVersion: String
    public let role: AppRole
    public var state: DiscoveryConnectionState

    public init(
        id: UUID,
        endpoint: NWEndpoint,
        serviceType: BonjourServiceType,
        displayName: String,
        platform: DevicePlatform,
        protocolVersion: String,
        role: AppRole,
        state: DiscoveryConnectionState = .discovered
    ) {
        self.id = id
        self.endpoint = endpoint
        self.serviceType = serviceType
        self.displayName = displayName
        self.platform = platform
        self.protocolVersion = protocolVersion
        self.role = role
        self.state = state
    }

    public var isProtocolCompatible: Bool {
        protocolVersion == NetworkConstants.protocolVersion
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum DiscoveryEvent: Sendable {
    case deviceAppeared(DiscoveredDevice)
    case deviceUpdated(DiscoveredDevice)
    case deviceRemoved(UUID)
    case browsingFailed(String)
    case advertisingFailed(String)
    case localNetworkPermissionRequired
}
