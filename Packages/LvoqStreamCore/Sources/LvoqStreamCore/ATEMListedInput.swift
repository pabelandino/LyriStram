import Foundation

/// Video connector on an entry or common ATEM. Audio-only ports are not sources.
public enum ATEMVideoPort: String, Sendable, Equatable, Codable {
    case hdmi
    case sdi
    case other

    public var title: String {
        switch self {
        case .hdmi: "HDMI"
        case .sdi: "SDI"
        case .other: "Entrada"
        }
    }
}

/// One external input the director can list next to the Wi-Fi cameras.
public struct ATEMListedInput: Identifiable, Sendable, Equatable {
    public let id: CameraSourceID
    public let displayName: String
    public let port: ATEMVideoPort
    public let isSimulated: Bool

    public init(id: CameraSourceID, displayName: String, port: ATEMVideoPort, isSimulated: Bool) {
        self.id = id
        self.displayName = displayName
        self.port = port
        self.isSimulated = isSimulated
    }

    /// Entry and common switchers used for the test rig and for labeling a connected unit.
    public static func simulatedMini() -> [ATEMListedInput] {
        (1...4).map { index in
            ATEMListedInput(
                id: simulatorID(index),
                displayName: "HDMI \(index)",
                port: .hdmi,
                isSimulated: true
            )
        }
    }

    public static func hardwareID(_ inputID: Int64) -> CameraSourceID {
        let suffix = String(format: "%012llx", UInt64(bitPattern: inputID) & 0xFFFFFFFFFFFF)
        let uuid = UUID(uuidString: "A7E41101-0000-4000-8000-\(suffix)") ?? UUID()
        return CameraSourceID(uuid)
    }

    private static func simulatorID(_ index: Int) -> CameraSourceID {
        let suffix = String(format: "%012x", index)
        return CameraSourceID(UUID(uuidString: "A7E45140-0000-4000-8000-\(suffix)")!)
    }
}
