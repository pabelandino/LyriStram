import SwiftUI
import EasyStreamCore

public struct DirectorSourcesPanel<Content: View>: View {
    let title: String
    let onBack: (() -> Void)?
    let onOpenSettings: (() -> Void)?
    let onOpenMonitor: (() -> Void)?
    @ViewBuilder let content: () -> Content
    @Environment(\.directorCompactChrome) private var compact

    public init(
        title: String = "Fuentes",
        onBack: (() -> Void)? = nil,
        onOpenSettings: (() -> Void)? = nil,
        onOpenMonitor: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.onBack = onBack
        self.onOpenSettings = onOpenSettings
        self.onOpenMonitor = onOpenMonitor
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    if let onBack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.backward")
                                .font(.subheadline.weight(.semibold))
                                .frame(width: 22, height: 22)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Cambiar rol")
                    }
                    Image(systemName: "video.fill")
                        .font(.subheadline)
                        .foregroundStyle(BroadcastTheme.previewGreen)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                }
                .fixedSize(horizontal: true, vertical: false)
                Spacer(minLength: 4)
                if onOpenSettings != nil || onOpenMonitor != nil {
                    Menu {
                        if let onOpenSettings {
                            Button("Ajustes del estudio", systemImage: "gearshape", action: onOpenSettings)
                        }
                        if let onOpenMonitor {
                            Button("Monitor", systemImage: "display.2", action: onOpenMonitor)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body)
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .menuStyle(.button)
                    .buttonStyle(.plain)
                    .fixedSize()
                    .accessibilityLabel("Ajustes")
                }
            }
            .padding(.horizontal, DirectorColumnHeaderMetrics.horizontalPadding)
            .frame(height: DirectorColumnHeaderMetrics.height)
            .frame(maxWidth: .infinity)
            .background(BroadcastTheme.panelElevated)

            Divider().overlay(BroadcastTheme.workspaceDivider)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: compact ? 10 : 14) {
                    content()
                }
                .padding(.horizontal, compact ? 8 : 14)
                .padding(.vertical, compact ? 8 : 14)
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
