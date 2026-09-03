#if os(macOS)
import SwiftUI

struct CameraSessionTabletChrome: ViewModifier {
    func body(content: Content) -> some View {
        content.listStyle(.inset)
    }
}
#endif
