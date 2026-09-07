#if os(iOS)
import SwiftUI
import EasyStreamCore
import EasyStreamCameraCapture
import EasyStreamUIComponents
import EasyStreamTransport
import UIKit

extension CameraSessionView {
    @ViewBuilder
    var platformSessionContent: some View {
        CameraSessionLandscapeLayout(
            viewModel: viewModel,
            intercomService: intercomService,
            showsControls: $showsControls,
            identity: identity,
            zoomBinding: zoomBinding,
            exposureBinding: exposureBinding,
            whiteBalanceBinding: whiteBalanceBinding
        )
    }
}
#endif
