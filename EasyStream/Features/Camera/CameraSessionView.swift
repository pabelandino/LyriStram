import SwiftUI
import EasyStreamCore
import EasyStreamCameraCapture
import EasyStreamUIComponents
import EasyStreamTransport

struct CameraSessionView: View {
    @State private var viewModel = CameraSessionViewModel()
    @State private var intercomService = TeamIntercomService()
    @State private var showsControls = true
    private let identity = DeviceIdentity.current()

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
#if os(iOS)
                if UIDevice.current.userInterfaceIdiom == .phone {
                    phoneSessionContent
                } else {
                    tabletSessionContent
                }
#else
                tabletSessionContent
#endif
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

#if os(iOS)
    private var phoneSessionContent: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                previewHeader
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                ZStack {
                    if let session = viewModel.localPreviewSession {
                        CameraPreviewView(session: session)
                            .frame(maxWidth: CameraStreamConfiguration.previewMaxWidth)
                            .aspectRatio(16 / 9, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    } else {
                        ProgressView("Iniciando cámara…")
                            .frame(maxWidth: .infinity)
                            .aspectRatio(16 / 9, contentMode: .fit)
                    }

                    if viewModel.isMuted {
                        Label("Silenciado", systemImage: "mic.slash.fill")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.black.opacity(0.55), in: Capsule())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(12)
                    }
                }
                .padding(.horizontal, 12)

                if showsControls {
                    ScrollView(.vertical, showsIndicators: true) {
                        controlsSheet
                    }
                    .frame(maxHeight: 360)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer(minLength: 0)
            }

            CameraTallyGlowOverlay(
                assignment: viewModel.switcherAssignment,
                placement: .screenEdge
            )
        }
        .animation(.easeInOut(duration: 0.25), value: showsControls)
    }

    private var previewHeader: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(identity.displayName)
                    .font(.headline)
                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .lineLimit(1)
            }

            Spacer()

            CameraAssignmentBadge(assignment: viewModel.switcherAssignment)

            Button {
                showsControls.toggle()
            } label: {
                Image(systemName: showsControls ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.85))
        }
    }

    private var controlsSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
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

            connectionSummary

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
        .padding(16)
        .broadcastPanel(elevated: true)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var connectionSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            BroadcastSectionHeader("Director", systemImage: "wifi")

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
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
                .disabled(viewModel.isReconnecting)
            }
        }
    }
#endif

    private var tabletSessionContent: some View {
        List {
            Section {
                ZStack(alignment: .topTrailing) {
                    if let session = viewModel.localPreviewSession {
                        CameraPreviewView(session: session)
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
#if os(macOS)
        .listStyle(.inset)
#endif
    }

    private var lensLabel: String {
        viewModel.imagingState.availableLenses
            .first { $0.kind == viewModel.imagingState.activeLens }?
            .localizedName ?? viewModel.imagingState.activeLens.displayName
    }

    private var zoomBinding: Binding<Double> {
        Binding(
            get: { viewModel.imagingState.zoomFactor },
            set: { viewModel.setZoom($0) }
        )
    }

    private var exposureBinding: Binding<Float> {
        Binding(
            get: { viewModel.imagingState.exposureBias },
            set: { viewModel.setExposureBias($0) }
        )
    }

    private var whiteBalanceBinding: Binding<WhiteBalanceModeOption> {
        Binding(
            get: { viewModel.imagingState.whiteBalance },
            set: { viewModel.setWhiteBalance($0) }
        )
    }
}

#if os(iOS)
import UIKit
#endif

#Preview {
    NavigationStack {
        CameraSessionView()
    }
}
