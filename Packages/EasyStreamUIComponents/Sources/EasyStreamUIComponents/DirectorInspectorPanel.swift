import SwiftUI
import EasyStreamCore

public struct DirectorInspectorPanel<Content: View>: View {
    @ViewBuilder let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(BroadcastTheme.studioAccent)
                Text("Inspector")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(BroadcastTheme.panelElevated)

            Divider().overlay(BroadcastTheme.workspaceDivider)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 14) {
                    content()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
#if os(macOS)
            .clipped()
#endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BroadcastTheme.panelBackground)
#if os(macOS)
        .compositingGroup()
#endif
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(BroadcastTheme.workspaceDivider)
                .frame(width: 1)
        }
    }
}
