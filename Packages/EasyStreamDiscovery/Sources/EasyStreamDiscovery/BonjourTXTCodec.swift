import Foundation
import Network
import EasyStreamCore

enum BonjourTXTCodec {
    static func makeRecord(identity: DeviceIdentity, role: AppRole) -> NWTXTRecord {
        NWTXTRecord([
            NetworkConstants.TXTKey.deviceID: identity.deviceID.uuidString,
            NetworkConstants.TXTKey.displayName: identity.displayName,
            NetworkConstants.TXTKey.protocolVersion: NetworkConstants.protocolVersion,
            NetworkConstants.TXTKey.platform: identity.platform.rawValue,
            NetworkConstants.TXTKey.role: role.rawValue,
        ])
    }

    static func decode(_ record: NWTXTRecord?) -> (
        deviceID: UUID,
        displayName: String,
        platform: DevicePlatform,
        protocolVersion: String,
        role: AppRole
    )? {
        guard let record else { return nil }

        guard
            let idString = stringValue(record, key: NetworkConstants.TXTKey.deviceID),
            let deviceID = UUID(uuidString: idString),
            let displayName = stringValue(record, key: NetworkConstants.TXTKey.displayName),
            let protocolVersion = stringValue(record, key: NetworkConstants.TXTKey.protocolVersion),
            let roleRaw = stringValue(record, key: NetworkConstants.TXTKey.role),
            let role = AppRole(rawValue: roleRaw)
        else {
            return nil
        }

        let platformRaw = stringValue(record, key: NetworkConstants.TXTKey.platform)
        let platform = platformRaw.flatMap(DevicePlatform.init(rawValue:)) ?? .unknown
        return (deviceID, displayName, platform, protocolVersion, role)
    }

    static func isEmpty(_ record: NWTXTRecord?) -> Bool {
        guard let record else { return true }
        return decode(record) == nil
            && stringValue(record, key: NetworkConstants.TXTKey.deviceID) == nil
    }

    private static func stringValue(_ record: NWTXTRecord, key: String) -> String? {
        guard let entry = record.getEntry(for: key) else { return nil }
        switch entry {
        case .string(let value):
            return value
        case .data(let data):
            return String(data: data, encoding: .utf8)
        case .empty, .none:
            return nil
        @unknown default:
            return nil
        }
    }
}

enum BonjourEndpointParser {
    static func serviceName(from endpoint: NWEndpoint) -> String? {
        if case .service(let name, _, _, _) = endpoint {
            return name
        }
        return nil
    }
}
