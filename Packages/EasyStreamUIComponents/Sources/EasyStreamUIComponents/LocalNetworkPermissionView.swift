import SwiftUI
import EasyStreamCore

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
