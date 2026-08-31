import SwiftUI
import EasyStreamCore

public struct ConnectionStatusBadge: View {
    let isActive: Bool
    let label: String

    public init(isActive: Bool, label: String) {
        self.isActive = isActive
        self.label = label
    }

    public var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isActive ? BroadcastTheme.previewGreen : Color.orange)
                .frame(width: 8, height: 8)
                .shadow(color: isActive ? BroadcastTheme.previewGreen.opacity(0.5) : .clear, radius: 4)
            Text(label)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(BroadcastTheme.panelElevated, in: Capsule())
        .overlay(Capsule().strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1))
    }
}

public struct DiscoveredDeviceRow: View {
    let device: DiscoveredDevice

    public init(device: DiscoveredDevice) {
        self.device = device
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: device.role == .camera ? "video.fill" : "rectangle.inset.filled.and.person.filled")
                .foregroundStyle(Color.accentColor)
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

public struct SignalStrengthView: View {
    let level: Int

    public init(level: Int) {
        self.level = max(0, min(level, 4))
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(index < level ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 4, height: CGFloat(6 + index * 3))
            }
        }
        .accessibilityLabel("Señal de red")
    }
}

public struct LocalNetworkPermissionView: View {
    let openSettings: () -> Void

    public init(openSettings: @escaping () -> Void) {
        self.openSettings = openSettings
    }

    public var body: some View {
        ContentUnavailableView {
            Label("Red local requerida", systemImage: "wifi.exclamationmark")
        } description: {
            Text("EasyStream necesita acceso a la red local para descubrir cámaras y directores en tu Wi‑Fi. Actívalo en Ajustes.")
        } actions: {
            Button("Abrir Ajustes", action: openSettings)
                .buttonStyle(.borderedProminent)
        }
    }
}

#if canImport(UIKit)
import UIKit

public enum PlatformSettings {
    public static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
#elseif canImport(AppKit)
import AppKit

public enum PlatformSettings {
    public static func openAppSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocalNetwork") {
            NSWorkspace.shared.open(url)
        }
    }
}
#endif
