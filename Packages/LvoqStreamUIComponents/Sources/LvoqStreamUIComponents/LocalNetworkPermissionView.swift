import SwiftUI
import LvoqStreamCore

public struct LocalNetworkPermissionView: View {
    let openSettings: () -> Void
    let onRetry: (() -> Void)?

    public init(openSettings: @escaping () -> Void, onRetry: (() -> Void)? = nil) {
        self.openSettings = openSettings
        self.onRetry = onRetry
    }

    public var body: some View {
        ContentUnavailableView {
            Label(BundleLocalization.string("network.local.required_title"), systemImage: "wifi.exclamationmark")
        } description: {
            VStack(alignment: .leading, spacing: 10) {
                Text(LvoqStreamNetworkMessages.localNetworkPermissionRequired)
#if os(macOS)
                Text(LvoqStreamNetworkMessages.localNetworkPermissionPromptHint)
                    .foregroundStyle(BroadcastTheme.subtleText)
#endif
            }
            .multilineTextAlignment(.center)
        } actions: {
            if let onRetry {
                Button(BundleLocalization.string("common.retry"), action: onRetry)
                    .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
            }
            Button(BundleLocalization.string("Abrir Ajustes"), action: openSettings)
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.controlAccent, isProminent: onRetry == nil))
        }
    }
}
