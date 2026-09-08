import SwiftUI
import EasyStreamUIComponents

struct DirectorStudioSettingsSidebarLabel: View {
    let tab: DirectorStudioSettingsTab

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(tab.title)
                Text(tab.subtitle)
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
        } icon: {
            Image(systemName: tab.systemImage)
        }
    }
}

struct DirectorStudioSettingsInfoCallout: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)
                .padding(.top, 1)

            Text(text)
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 2)
    }
}

/// Defers heavy settings UI until after the current run loop so PROG Metal keeps presenting frames.
struct DirectorStudioSettingsDeferredDetail<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @State private var isReady = false

    var body: some View {
        Group {
            if isReady {
                content()
            } else {
                ProgressView("Cargando ajustes…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await Task.yield()
            isReady = true
        }
    }
}

/// Yields one run loop turn before presenting auxiliary UI so the program bus is not starved.
enum DirectorModalPresentation {
    @MainActor
    static func afterYield(_ action: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            await Task.yield()
            action()
        }
    }
}
