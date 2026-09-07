import SwiftUI
import EasyStreamCore

public struct DirectorInspectorSection<Content: View>: View {
    let title: String
    let systemImage: String?
    @ViewBuilder let content: () -> Content

    public init(_ title: String, systemImage: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BroadcastSectionHeader(title, systemImage: systemImage)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .broadcastPanel(elevated: true)
    }
}
