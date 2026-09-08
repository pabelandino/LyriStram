#if os(iOS) || os(macOS)
import SwiftUI
import EasyStreamCore
import EasyStreamCameraCapture
import EasyStreamUIComponents
#if os(iOS)
import UIKit
#endif

struct CameraSessionLandscapePreviewHeader: View {
    let displayName: String
    let statusMessage: String
    let streamState: StreamConnectionState
    let isReconnecting: Bool
    let assignment: CameraSwitcherAssignment
    let layout: CameraSessionLayoutKind
    @Binding var showsControls: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                BroadcastConnectionStatusLine(
                    message: statusMessage,
                    streamState: streamState,
                    isReconnecting: isReconnecting,
                    font: .caption2
                )
            }

            Spacer(minLength: 4)

            CameraAssignmentBadge(assignment: assignment)

            if layout == .phone {
                Button {
                    showsControls.toggle()
                } label: {
                    Image(systemName: showsControls ? "sidebar.right" : "sidebar.left")
                        .font(.body.weight(.semibold))
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(0.85))
                .accessibilityLabel(showsControls ? "Ocultar controles" : "Mostrar controles")
            }
        }
    }
}
#endif
