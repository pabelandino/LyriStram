import SwiftUI
import EasyStreamCore
import EasyStreamCameraCapture
import EasyStreamUIComponents
import EasyStreamTransport

struct CameraSessionView: View {
    @State var viewModel = CameraSessionViewModel()
    @State var intercomService = TeamIntercomService()
    @State var showsControls = true
    let identity = DeviceIdentity.current()

    var body: some View {
        Group {
            if viewModel.needsLocalNetworkPermission {
                LocalNetworkPermissionView(
                    openSettings: PlatformSettings.openAppSettings,
                    onRetry: { viewModel.retryLocalNetworkAccess(identity: identity) }
                )
            } else if viewModel.permissionStatus == .denied || viewModel.permissionStatus == .restricted {
                cameraPermissionView
            } else {
                platformSessionContent
            }
        }
        .navigationTitle("Cámara")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ConnectionStatusBadge(
                    isActive: viewModel.streamState == .connected,
                    label: streamBadgeLabel
                )
            }
        }
        .onAppear {
            viewModel.start(identity: identity)
        }
        .onChange(of: viewModel.streamState) { _, state in
            switch state {
            case .connected:
                intercomService.start(identity: identity, role: .camera)
            case .failed, .disconnected, .idle:
                intercomService.stop()
            default:
                break
            }
        }
        .onDisappear {
            viewModel.stop()
            intercomService.stop()
        }
    }

    private var streamBadgeLabel: String {
        switch viewModel.streamState {
        case .connected: "En vivo"
        case .connecting, .signaling: "Conectando"
        default: viewModel.isRunning ? "Visible" : "Detenido"
        }
    }

    private var cameraPermissionView: some View {
        ContentUnavailableView {
            Label("Cámara requerida", systemImage: "camera.fill")
        } description: {
            Text("EasyStream necesita acceso a la cámara para enviar video al Director.")
        } actions: {
            Button("Abrir Ajustes", action: PlatformSettings.openAppSettings)
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
        }
    }

    var zoomBinding: Binding<Double> {
        Binding(
            get: { viewModel.imagingState.zoomFactor },
            set: { viewModel.setZoom($0) }
        )
    }

    var exposureBinding: Binding<Float> {
        Binding(
            get: { viewModel.imagingState.exposureBias },
            set: { viewModel.setExposureBias($0) }
        )
    }

    var whiteBalanceBinding: Binding<WhiteBalanceModeOption> {
        Binding(
            get: { viewModel.imagingState.whiteBalance },
            set: { viewModel.setWhiteBalance($0) }
        )
    }
}

#Preview {
    NavigationStack {
        CameraSessionView()
    }
}
