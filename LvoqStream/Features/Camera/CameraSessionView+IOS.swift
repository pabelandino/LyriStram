#if os(iOS)
import SwiftUI
import LvoqStreamCore
import LvoqStreamCameraCapture
import LvoqStreamUIComponents
import LvoqStreamTransport
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
