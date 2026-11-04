#if os(iOS) || os(macOS)
import SwiftUI
#if os(iOS)
import UIKit
#endif

struct CameraSessionLandscapeChrome: ViewModifier {
#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif

    func body(content: Content) -> some View {
#if os(iOS)
        content
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { applyOrientation() }
            .onChange(of: horizontalSizeClass) { _, _ in applyOrientation() }
            .onDisappear { AppOrientationPolicy.unlock() }
#else
        content
#endif
    }

#if os(iOS)
    /// Compact outer display and the fully open Duo inner display stay landscape. iPad can rotate.
    private func applyOrientation() {
        let phone = UIDevice.current.userInterfaceIdiom == .phone
        AppOrientationPolicy.apply(phone: phone, regularWidth: horizontalSizeClass == .regular)
    }
#endif
}
#endif
