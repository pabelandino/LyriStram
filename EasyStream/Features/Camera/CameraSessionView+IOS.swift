#if os(iOS)
import SwiftUI
import EasyStreamCore
import EasyStreamCameraCapture
import EasyStreamUIComponents
import EasyStreamTransport
import UIKit

extension CameraSessionView {
    @ViewBuilder
    var platformSessionContent: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            phoneSessionContent
        } else {
            tabletSessionContent
        }
    }

    var phoneSessionContent: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                HStack(spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        if let session = viewModel.localPreviewSession {
                            CameraPreviewView(session: session)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(16 / 9, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        } else {
                            ProgressView("Iniciando cámara…")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(16 / 9, contentMode: .fit)
                        }

                        if viewModel.isMuted {
                            Label("Silenciado", systemImage: "mic.slash.fill")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.black.opacity(0.55), in: Capsule())
                                .foregroundStyle(.white)
                                .padding(12)
                        }
                    }
                    .padding(.leading, 12)
                    .padding(.vertical, 12)
                    .frame(width: max(geometry.size.width * 0.62, 280))

                    if showsControls {
                        ScrollView(.vertical, showsIndicators: true) {
                            VStack(alignment: .leading, spacing: 12) {
                                previewHeader
                                controlsSheet
                            }
                            .padding(.trailing, 12)
                            .padding(.vertical, 12)
                        }
                        .frame(width: geometry.size.width * 0.38)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }

                CameraTallyGlowOverlay(
                    assignment: viewModel.switcherAssignment,
                    placement: .screenEdge
                )
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showsControls)
        .onAppear { AppOrientationPolicy.lockLandscape() }
        .onDisappear { AppOrientationPolicy.unlock() }
    }

    var previewHeader: some View {
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

    var controlsSheet: some View {
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

    var connectionSummary: some View {
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
}
#endif
