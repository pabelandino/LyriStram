#if os(macOS)
import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorPreviewMonitorSettingsWindowContent: View {
    @Bindable var previewMonitor: DirectorPreviewMonitorStore
    let onOpenMonitor: () -> Void

    var body: some View {
        PreviewMonitorSettingsSheet(
            settings: $previewMonitor.settings,
            onOpenMonitor: onOpenMonitor
        )
    }
}
#endif
