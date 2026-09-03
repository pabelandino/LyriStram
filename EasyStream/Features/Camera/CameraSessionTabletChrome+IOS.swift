#if os(iOS)
import SwiftUI

struct CameraSessionTabletChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listStyle(.insetGrouped)
            .onAppear { AppOrientationPolicy.lockLandscape() }
            .onDisappear { AppOrientationPolicy.unlock() }
    }
}
#endif
