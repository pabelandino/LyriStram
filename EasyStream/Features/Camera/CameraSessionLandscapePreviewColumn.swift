#if os(iOS) || os(macOS)
import SwiftUI
import AVFoundation
import EasyStreamCore
import EasyStreamCameraCapture
import EasyStreamUIComponents

struct CameraSessionLandscapePreviewColumn: View {
    let metrics: CameraSessionLayoutMetrics
    let layout: CameraSessionLayoutKind
    let displayName: String
    let statusMessage: String
    let streamState: StreamConnectionState
    let isReconnecting: Bool
    let assignment: CameraSwitcherAssignment
    let isMuted: Bool
    let previewSession: AVCaptureSession?
    @Binding var showsControls: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CameraSessionLandscapePreviewHeader(
                displayName: displayName,
                statusMessage: statusMessage,
                streamState: streamState,
                isReconnecting: isReconnecting,
                assignment: assignment,
                layout: layout,
                showsControls: $showsControls
            )

            ZStack(alignment: .topTrailing) {
                Group {
                    if let previewSession {
                        CameraPreviewView(session: previewSession)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(BroadcastTheme.panelElevated)
                            ProgressView("Iniciando cámara…")
                                .font(.caption)
                                .foregroundStyle(BroadcastTheme.subtleText)
                        }
                    }
                }
                .frame(width: metrics.videoWidth, height: metrics.videoHeight)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                }
                .overlay {
                    CameraTallyGlowOverlay(
                        assignment: assignment,
                        placement: .contentFrame(cornerRadius: 14)
                    )
                }
                .overlay(alignment: .bottom) {
                    if BroadcastConnectionProgress.isInProgress(
                        streamState: streamState,
                        statusMessage: statusMessage,
                        isReconnecting: isReconnecting
                    ) {
                        VStack(spacing: 6) {
                            BroadcastConnectionProgressBar(
                                progress: BroadcastConnectionProgress.fraction(
                                    streamState: streamState,
                                    statusMessage: statusMessage,
                                    isReconnecting: isReconnecting
                                ),
                                tint: BroadcastConnectionProgress.tint(
                                    streamState: streamState,
                                    statusMessage: statusMessage,
                                    isReconnecting: isReconnecting
                                ),
                                height: 6
                            )
                            Text(statusMessage)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.white.opacity(0.88))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.black.opacity(0.62), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding(10)
                    }
                }

                if isMuted {
                    Label("Silenciado", systemImage: "mic.slash.fill")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.62), in: Capsule())
                        .foregroundStyle(.white)
                        .padding(8)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(width: metrics.videoWidth + 4, alignment: .topLeading)
    }
}
#endif
