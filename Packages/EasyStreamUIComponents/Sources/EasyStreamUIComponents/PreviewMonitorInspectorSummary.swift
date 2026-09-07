import SwiftUI
import EasyStreamCore

public struct PreviewMonitorInspectorSummary: View {
    let layoutName: String
    let onOpenMonitor: () -> Void
    let onConfigure: () -> Void

    public init(
        layoutName: String,
        onOpenMonitor: @escaping () -> Void,
        onConfigure: @escaping () -> Void
    ) {
        self.layoutName = layoutName
        self.onOpenMonitor = onOpenMonitor
        self.onConfigure = onConfigure
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Grid en segunda pantalla · \(layoutName)")
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onOpenMonitor) {
                Label("Abrir monitor", systemImage: "display.2")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
            .controlSize(.regular)

            Button("Configurar ajustes…", action: onConfigure)
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .controlSize(.regular)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
