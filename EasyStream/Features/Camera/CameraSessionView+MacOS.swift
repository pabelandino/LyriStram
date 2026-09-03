#if os(macOS)
import SwiftUI

extension CameraSessionView {
    @ViewBuilder
    var platformSessionContent: some View {
        tabletSessionContent
    }
}
#endif
