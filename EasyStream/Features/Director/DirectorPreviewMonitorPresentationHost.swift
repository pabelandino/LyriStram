import SwiftUI
import EasyStreamUIComponents

/// Routes preview multiview to an external `UIWindow` (iPad) or full-screen cover fallback.
struct DirectorPreviewMonitorPresentationHost: View {
    @Binding var isPresented: Bool

    var body: some View {
#if os(iOS)
        Color.clear
            .frame(width: 0, height: 0)
            .fullScreenCover(isPresented: $isPresented, onDismiss: dismissExternalIfNeeded) {
                DirectorPreviewMonitorFullScreenContent {
                    isPresented = false
                }
            }
            .onAppear {
                PreviewMonitorExternalDisplayController.shared.installLifecycleObserversIfNeeded()
            }
#else
        EmptyView()
#endif
    }

#if os(iOS)
    private func dismissExternalIfNeeded() {
        PreviewMonitorExternalDisplayController.shared.dismiss()
    }
#endif
}

#if os(iOS)
private struct DirectorPreviewMonitorFullScreenContent: View {
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            DirectorPreviewMonitorWindowView()
                .navigationTitle("Monitor multiview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Cerrar", action: onClose)
                    }
                }
        }
        .broadcastStudioWindowStyle()
    }
}
#endif
