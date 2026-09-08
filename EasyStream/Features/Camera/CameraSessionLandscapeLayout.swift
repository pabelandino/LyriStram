#if os(iOS) || os(macOS)
import SwiftUI
import EasyStreamCore
import EasyStreamCameraCapture
import EasyStreamUIComponents
import EasyStreamTransport
import AVFoundation

/// Landscape camera dashboard — shared layout for iPhone, iPad and Mac.
struct CameraSessionLandscapeLayout: View {
    @Bindable var viewModel: CameraSessionViewModel
    @Bindable var intercomService: TeamIntercomService
    @Binding var showsControls: Bool
    let identity: DeviceIdentity
    let zoomBinding: Binding<Double>
    let exposureBinding: Binding<Float>
    let whiteBalanceBinding: Binding<WhiteBalanceModeOption>

    private let layoutKind = CameraSessionLayoutKind.current

    var body: some View {
        GeometryReader { geometry in
            let metrics = CameraSessionLayoutMetrics(size: geometry.size, layout: layoutKind)

            ZStack {
                Color.black.ignoresSafeArea()

                HStack(alignment: .top, spacing: metrics.columnSpacing) {
                    CameraSessionLandscapePreviewColumn(
                        metrics: metrics,
                        layout: layoutKind,
                        displayName: identity.displayName,
                        statusMessage: viewModel.statusMessage,
                        streamState: viewModel.streamState,
                        isReconnecting: viewModel.isReconnecting,
                        assignment: viewModel.switcherAssignment,
                        isMuted: viewModel.isMuted,
                        previewSession: viewModel.localPreviewSession,
                        showsControls: $showsControls
                    )

                    CameraSessionLandscapeControlsColumn(
                        metrics: metrics,
                        layout: layoutKind,
                        showsControls: $showsControls,
                        viewModel: viewModel,
                        intercomService: intercomService,
                        zoomBinding: zoomBinding,
                        exposureBinding: exposureBinding,
                        whiteBalanceBinding: whiteBalanceBinding
                    )
                }
                .padding(.horizontal, metrics.edgePadding)
                .padding(.vertical, metrics.edgePadding)

                CameraTallyGlowOverlay(
                    assignment: viewModel.switcherAssignment,
                    placement: .screenEdge
                )
            }
        }
        .modifier(CameraSessionLandscapeChrome())
        .animation(.easeInOut(duration: 0.22), value: showsControls)
    }
}
#endif
