import Foundation
import Network

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum DevicePlatform: String, Sendable, Codable, CaseIterable {
    case iPhone
    case iPad
    case mac
    case unknown

    public var displayName: String {
        switch self {
        case .iPhone: "iPhone"
        case .iPad: "iPad"
        case .mac: "Mac"
        case .unknown: "Desconocido"
        }
    }
}

/// Stable identity for this installation, persisted across launches.
public struct DeviceIdentity: Sendable, Codable, Equatable {
    public let deviceID: UUID
    public let displayName: String
    public let platform: DevicePlatform

    public init(deviceID: UUID, displayName: String, platform: DevicePlatform) {
        self.deviceID = deviceID
        self.displayName = displayName
        self.platform = platform
    }

    public static func current(displayName: String? = nil) -> DeviceIdentity {
        let id = persistedDeviceID()
        let name = displayName ?? defaultDisplayName()
        return DeviceIdentity(deviceID: id, displayName: name, platform: currentPlatform())
    }

    private static func defaultDisplayName() -> String {
        #if os(iOS)
        return UIDevice.current.name
        #elseif os(macOS)
        return Host.current().localizedName ?? ProcessInfo.processInfo.hostName
        #else
        return "EasyStream"
        #endif
    }

    private static func persistedDeviceID() -> UUID {
        let key = "com.easystream.deviceID"
        if let stored = UserDefaults.standard.string(forKey: key),
           let uuid = UUID(uuidString: stored) {
            return uuid
        }
        let uuid = UUID()
        UserDefaults.standard.set(uuid.uuidString, forKey: key)
        return uuid
    }

    public static func currentPlatform() -> DevicePlatform {
        #if os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return .iPhone
        case .pad: return .iPad
        default: return .unknown
        }
        #elseif os(macOS)
        return .mac
        #else
        return .unknown
        #endif
    }

    /// Suggested role based on device form factor (non-binding).
    public static var suggestedRole: AppRole {
        switch currentPlatform() {
        case .iPhone: .camera
        case .iPad, .mac: .director
        case .unknown: .camera
        }
    }
}
