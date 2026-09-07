import SwiftUI
import EasyStreamCore

public struct PreviewMonitorSettingsSheet: View {
    @Binding var settings: PreviewMonitorSettings
    let onOpenMonitor: () -> Void
    @Environment(\.dismiss) private var dismiss

    public init(settings: Binding<PreviewMonitorSettings>, onOpenMonitor: @escaping () -> Void) {
        _settings = settings
        self.onOpenMonitor = onOpenMonitor
    }

    public var body: some View {
        NavigationStack {
            PreviewMonitorSettingsForm(settings: $settings, onOpenMonitor: onOpenMonitor)
                .navigationTitle("Monitor multiview")
                .background(BroadcastTheme.panelBackground)
                .broadcastStudioChrome()
#if os(macOS)
                .frame(minWidth: 480, minHeight: 560)
#endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Listo") { dismiss() }
                    }
                }
        }
#if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
#endif
    }
}
