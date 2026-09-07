import SwiftUI
import EasyStreamCore

public struct DirectorSourcesPanel<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    public init(title: String = "Fuentes", @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "video.fill")
                    .foregroundStyle(BroadcastTheme.previewGreen)
                Text(title)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BroadcastTheme.panelBackground)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(BroadcastTheme.workspaceDivider)
                .frame(width: 1)
        }
    }
}
