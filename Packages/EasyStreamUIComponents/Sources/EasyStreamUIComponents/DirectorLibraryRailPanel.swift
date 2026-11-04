import SwiftUI
import EasyStreamCore

/// Narrow right rail hosting the media library.
public struct DirectorLibraryRailPanel<Content: View>: View {
    @ViewBuilder let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    @Environment(\.directorCompactChrome) private var compact

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.subheadline)
                    .foregroundStyle(BroadcastTheme.studioAccent)
                Text("Biblioteca")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Spacer(minLength: 4)
            }
            .padding(.horizontal, DirectorColumnHeaderMetrics.horizontalPadding)
            .frame(height: DirectorColumnHeaderMetrics.height)
            .frame(maxWidth: .infinity)
            .background(BroadcastTheme.panelElevated)

            Divider().overlay(BroadcastTheme.workspaceDivider)

            ScrollView(.vertical, showsIndicators: true) {
                content()
                    .padding(.horizontal, compact ? 6 : 10)
                    .padding(.vertical, compact ? 6 : 10)
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
