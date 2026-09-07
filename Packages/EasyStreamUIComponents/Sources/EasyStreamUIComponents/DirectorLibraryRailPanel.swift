import SwiftUI
import EasyStreamCore

/// Narrow right rail hosting the media library.
public struct DirectorLibraryRailPanel<Content: View>: View {
    @ViewBuilder let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundStyle(BroadcastTheme.studioAccent)
                Text("Biblioteca")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(BroadcastTheme.panelElevated)

            Divider().overlay(BroadcastTheme.workspaceDivider)

            ScrollView(.vertical, showsIndicators: true) {
                content()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
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
