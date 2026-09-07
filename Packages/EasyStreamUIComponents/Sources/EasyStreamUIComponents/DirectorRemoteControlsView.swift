import SwiftUI
import EasyStreamCore

public struct DirectorRemoteControlsView: View {
    let cameraName: String
    let settings: RemoteCameraSettings
    let connectionState: StreamConnectionState
    let onMutedChange: (Bool) -> Void
    let onZoomChange: (Double) -> Void
    let onExposureChange: (Float) -> Void
    let onWhiteBalanceChange: (String) -> Void
    let onLensChange: (String) -> Void
    let onReconnect: () -> Void

    public init(
        cameraName: String,
        settings: RemoteCameraSettings,
        connectionState: StreamConnectionState = .connected,
        onMutedChange: @escaping (Bool) -> Void,
        onZoomChange: @escaping (Double) -> Void,
        onExposureChange: @escaping (Float) -> Void,
        onWhiteBalanceChange: @escaping (String) -> Void,
        onLensChange: @escaping (String) -> Void,
        onReconnect: @escaping () -> Void = {}
    ) {
        self.cameraName = cameraName
        self.settings = settings
        self.connectionState = connectionState
        self.onMutedChange = onMutedChange
        self.onZoomChange = onZoomChange
        self.onExposureChange = onExposureChange
        self.onWhiteBalanceChange = onWhiteBalanceChange
        self.onLensChange = onLensChange
        self.onReconnect = onReconnect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DirectorRemoteControlsHeader(
                cameraName: cameraName,
                connectionState: connectionState
            )

            Button(action: onReconnect) {
                Label(reconnectButtonTitle, systemImage: "arrow.clockwise.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BroadcastGlowButtonStyle(
                tint: connectionState == .connected ? BroadcastTheme.subtleText : BroadcastTheme.studioAccent,
                isProminent: connectionState != .connected
            ))

            Toggle(isOn: Binding(
                get: { settings.isMuted },
                set: { onMutedChange($0) }
            )) {
                Label("Silenciar micrófono", systemImage: settings.isMuted ? "mic.slash.fill" : "mic.fill")
            }
            .toggleStyle(.switch)

            DirectorRemoteLensPicker(
                activeLens: RemoteLensOption(rawValue: settings.activeLens) ?? .wide,
                onLensChange: onLensChange
            )

            DirectorRemoteZoomControl(
                zoomFactor: settings.zoomFactor,
                onZoomChange: onZoomChange
            )

            DirectorRemoteExposureControl(
                exposureBias: settings.exposureBias,
                onExposureChange: onExposureChange
            )

            DirectorRemoteWhiteBalancePicker(
                mode: RemoteWhiteBalanceOption(rawValue: settings.whiteBalance) ?? .auto,
                onWhiteBalanceChange: onWhiteBalanceChange
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var reconnectButtonTitle: String {
        connectionState == .connected ? "Forzar reconexión" : "Reconectar cámara"
    }
}
