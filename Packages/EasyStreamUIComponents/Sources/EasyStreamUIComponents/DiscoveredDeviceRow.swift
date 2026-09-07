import SwiftUI
import EasyStreamCore

public struct DiscoveredDeviceRow: View {
    let device: DiscoveredDevice

    public init(device: DiscoveredDevice) {
        self.device = device
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: device.role == .camera ? "video.fill" : "rectangle.inset.filled.and.person.filled")
                .foregroundStyle(BroadcastTheme.studioAccent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.displayName)
                    .font(.headline)
                Text("\(device.platform.displayName) · v\(device.protocolVersion)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if device.isProtocolCompatible {
                SignalStrengthView(level: 4)
            } else {
                Text("Incompatible")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}
