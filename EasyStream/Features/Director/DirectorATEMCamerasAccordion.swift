import SwiftUI
import EasyStreamUIComponents

/// Cameras list only. Preview and the external monitor keep one cell per ATEM input.
struct DirectorATEMCamerasAccordion: View {
    let viewModel: DirectorSessionViewModel
    let sources: [ConnectedCameraSource]
    @State private var isExpanded = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(sources) { source in
                    DirectorCameraSidebarRow(viewModel: viewModel, source: source)
                }
            }
            .padding(.top, 4)
        } label: {
            HStack(spacing: 8) {
                Text("ATEM")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BroadcastTheme.primaryText)
                Text("\(sources.count)")
                    .font(.caption)
                    .foregroundStyle(BroadcastTheme.subtleText)
                Spacer(minLength: 0)
            }
            .frame(minHeight: 44)
        }
        .tint(BroadcastTheme.primaryText)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(BroadcastTheme.panelElevated.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(BroadcastTheme.panelBorder, lineWidth: 1)
        }
        .accessibilityLabel("ATEM")
    }
}
