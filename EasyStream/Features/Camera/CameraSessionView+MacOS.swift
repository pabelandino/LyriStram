#if os(macOS)
import SwiftUI

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
