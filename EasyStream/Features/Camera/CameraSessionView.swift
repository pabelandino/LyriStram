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

    var tabletSessionContent: some View {
        List {
            Section {
                ZStack(alignment: .topTrailing) {
                    if let session = viewModel.localPreviewSession {
                        CameraPreviewView(session: session)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(16 / 9, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        ProgressView("Iniciando cámara…")
                            .frame(maxWidth: .infinity)
                            .aspectRatio(16 / 9, contentMode: .fit)
                    }

                    CameraAssignmentBadge(assignment: viewModel.switcherAssignment)
                        .padding(8)
                }
                .overlay {
                    CameraTallyGlowOverlay(
                        assignment: viewModel.switcherAssignment,
                        placement: .contentFrame(cornerRadius: 12)
                    )
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            Section("Controles") {
                CameraClientControlsView(
                    isMuted: $viewModel.isMuted,
                    zoomFactor: zoomBinding,
                    exposureBias: exposureBinding,
                    whiteBalance: whiteBalanceBinding,
                    availableLenses: viewModel.imagingState.availableLenses,
                    activeLens: viewModel.imagingState.activeLens,
                    zoomRange: viewModel.imagingState.minZoomFactor...viewModel.imagingState.maxZoomFactor,
                    exposureRange: viewModel.imagingState.minExposureBias...viewModel.imagingState.maxExposureBias,
                    onLensSelected: { viewModel.selectLens($0) }
                )
            }

            Section("Intercom") {
                TeamIntercomPanel(
                    peers: intercomService.peers,
                    statusMessage: intercomService.statusMessage,
                    isEnabled: intercomService.isEnabled,
                    isTalking: intercomService.isTalking,
                    isActivating: intercomService.isActivating,
                    targetPeerID: intercomService.targetPeerID,
                    needsLocalNetworkPermission: intercomService.needsLocalNetworkPermission,
                    onOpenSettings: PlatformSettings.openAppSettings,
                    onTargetPeerChange: { intercomService.setTargetPeer($0) },
                    onEnabledChange: { intercomService.isEnabled = $0 },
                    onTalkBegin: { intercomService.toggleTalking() },
                    onTalkEnd: { intercomService.toggleTalking() }
                )
            }

            Section("Director") {
                DirectorConnectionPanel(
                    directors: viewModel.availableDirectors,
                    selectedDirectorID: viewModel.selectedDirectorID,
                    connectedDirectorID: viewModel.connectedDirectorID,
                    streamState: viewModel.streamState,
                    statusMessage: viewModel.statusMessage,
                    onSelect: { viewModel.selectDirector($0) }
                )

                if viewModel.canReconnect {
                    Button {
                        viewModel.reconnect()
                    } label: {
                        Label(
                            viewModel.isReconnecting ? "Reconectando…" : "Reconectar al Director",
                            systemImage: "arrow.clockwise.circle.fill"
                        )
                    }
                    .disabled(viewModel.isReconnecting)
                }
            }
        }
        .modifier(CameraSessionTabletChrome())
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
