import SwiftUI
import EasyStreamCore

public struct PreviewMonitorSettingsPanel: View {
    @Binding var settings: PreviewMonitorSettings
    let onOpenMonitor: () -> Void

    public init(settings: Binding<PreviewMonitorSettings>, onOpenMonitor: @escaping () -> Void) {
        _settings = settings
        self.onOpenMonitor = onOpenMonitor
    }

    public var body: some View {
        PreviewMonitorSettingsForm(settings: $settings, onOpenMonitor: onOpenMonitor)
    }
}
