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
    let assignment: CameraSwitcherAssignment
    let layout: CameraSessionLayoutKind
    @Binding var showsControls: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(statusMessage)
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
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
