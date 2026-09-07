#if os(iOS) || os(macOS)
import SwiftUI
#if os(iOS)
import UIKit
#endif

struct CameraSessionLandscapeChrome: ViewModifier {
    func body(content: Content) -> some View {
#if os(iOS)
        content
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { AppOrientationPolicy.lockLandscape() }
            .onDisappear { AppOrientationPolicy.unlock() }
#else
        content
#endif
    }
}
#endif
