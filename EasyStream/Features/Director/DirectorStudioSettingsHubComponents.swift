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

/// Defers heavy settings UI until PROG Metal has painted a few frames.
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
            await DirectorModalPresentation.deferHeavyUI()
            isReady = true
        }
    }
}

/// Yields several run-loop turns before presenting auxiliary UI so the program bus is not starved.
enum DirectorModalPresentation {
    /// ~2 display frames at 60 Hz — enough for MTKView to present while SwiftUI builds modals.
    static let heavyUIDelayNanoseconds: UInt64 = 34_000_000

    @MainActor
    static func deferHeavyUI() async {
        await Task.yield()
        await Task.yield()
        await Task.yield()
        try? await Task.sleep(nanoseconds: heavyUIDelayNanoseconds)
    }

    @MainActor
    static func afterYield(_ action: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            await deferHeavyUI()
            action()
        }
    }
}
