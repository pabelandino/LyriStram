#if os(iOS) || os(macOS)
import SwiftUI
import LvoqStreamCore
import LvoqStreamUIComponents

struct CameraSessionDirectorCard: View {
    let directors: [DiscoveredDevice]
    let selectedDirectorID: UUID?
    let connectedDirectorID: UUID?
    let streamState: StreamConnectionState
    let statusMessage: String
    let canReconnect: Bool
    let isReconnecting: Bool
    let onSelectDirector: (DiscoveredDevice) -> Void
    let onReconnect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BroadcastSectionHeader(BundleLocalization.string("common.director"), systemImage: "wifi")

            DirectorConnectionPanel(
                directors: directors,
                selectedDirectorID: selectedDirectorID,
                connectedDirectorID: connectedDirectorID,
                streamState: streamState,
                statusMessage: statusMessage,
                isReconnecting: isReconnecting,
                onSelect: onSelectDirector
            )

            if canReconnect {
                Button(action: onReconnect) {
                    Label(
                        isReconnecting
                            ? BundleLocalization.string("session.reconnecting")
                            : BundleLocalization.string("camera.reconnect_to_director"),
                        systemImage: "arrow.clockwise.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
                .disabled(isReconnecting)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .broadcastPanel(elevated: true)
    }
}
#endif
