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

public struct DirectorConnectionPanel: View {
    let directors: [DiscoveredDevice]
    let selectedDirectorID: UUID?
    let connectedDirectorID: UUID?
    let streamState: StreamConnectionState
    let statusMessage: String
    let onSelect: (DiscoveredDevice) -> Void

    public init(
        directors: [DiscoveredDevice],
        selectedDirectorID: UUID?,
        connectedDirectorID: UUID?,
        streamState: StreamConnectionState,
        statusMessage: String,
        onSelect: @escaping (DiscoveredDevice) -> Void
    ) {
        self.directors = directors
        self.selectedDirectorID = selectedDirectorID
        self.connectedDirectorID = connectedDirectorID
        self.streamState = streamState
        self.statusMessage = statusMessage
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(statusMessage)
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)

            if directors.isEmpty {
                Text("Esperando un Director en la red local…")
                    .font(.caption)
                    .foregroundStyle(BroadcastTheme.subtleText)
            } else if directors.count == 1, let director = directors.first {
                directorRow(director, showsSelector: false)
            } else {
                Text("Director de destino")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BroadcastTheme.subtleText)

                ForEach(directors) { director in
                    Button {
                        onSelect(director)
                    } label: {
                        directorRow(director, showsSelector: true)
                    }
                    .buttonStyle(.plain)
                }

                Text("El video se envía solo al Director seleccionado. El intercom sigue siendo independiente.")
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
        }
    }

    @ViewBuilder
    private func directorRow(_ director: DiscoveredDevice, showsSelector: Bool) -> some View {
        HStack(spacing: 10) {
            if showsSelector {
                Image(systemName: isSelected(director) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected(director) ? BroadcastTheme.studioAccent : BroadcastTheme.subtleText)
            } else {
                Image(systemName: "rectangle.inset.filled.and.person.filled")
                    .foregroundStyle(BroadcastTheme.studioAccent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(director.displayName)
                    .font(.subheadline.weight(.medium))
                Text(director.platform.displayName)
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }

            Spacer(minLength: 0)

            connectionBadge(for: director)

            if connectedDirectorID != director.id, !director.isProtocolCompatible {
                Text("Incompatible")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            isSelected(director) ? BroadcastTheme.studioAccent.opacity(0.12) : Color.clear,
            in: RoundedRectangle(cornerRadius: 8)
        )
    }

    private func isSelected(_ director: DiscoveredDevice) -> Bool {
        selectedDirectorID == director.id
            || (selectedDirectorID == nil && connectedDirectorID == director.id)
    }

    @ViewBuilder
    private func connectionBadge(for director: DiscoveredDevice) -> some View {
        let isActiveTarget = connectedDirectorID == director.id
            || (selectedDirectorID == director.id && (streamState == .connecting || streamState == .signaling))

        if isActiveTarget {
            switch streamState {
            case .connected:
                BroadcastTallyPill("En vivo", color: BroadcastTheme.previewGreen)
            case .connecting, .signaling:
                BroadcastTallyPill("Conectando", color: BroadcastTheme.liveAmber)
            case .failed:
                BroadcastTallyPill("Error", color: BroadcastTheme.programRed)
            default:
                EmptyView()
            }
        }
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
    let onRetry: (() -> Void)?

    public init(openSettings: @escaping () -> Void, onRetry: (() -> Void)? = nil) {
        self.openSettings = openSettings
        self.onRetry = onRetry
    }

    public var body: some View {
        ContentUnavailableView {
            Label("Red local requerida", systemImage: "wifi.exclamationmark")
        } description: {
            VStack(alignment: .leading, spacing: 10) {
                Text(EasyStreamNetworkMessages.localNetworkPermissionRequired)
#if os(macOS)
                Text(EasyStreamNetworkMessages.localNetworkPermissionPromptHint)
                    .foregroundStyle(BroadcastTheme.subtleText)
#endif
            }
            .multilineTextAlignment(.center)
        } actions: {
            if let onRetry {
                Button("Reintentar", action: onRetry)
                    .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
            }
            Button("Abrir Ajustes", action: openSettings)
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.controlAccent, isProminent: onRetry == nil))
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
        let candidates = [
            "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_LocalNetwork",
            "x-apple.systempreferences:com.apple.preference.security?Privacy_LocalNetwork",
        ]
        for candidate in candidates {
            guard let url = URL(string: candidate) else { continue }
            if NSWorkspace.shared.open(url) { return }
        }
    }
}
#endif
