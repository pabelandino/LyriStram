#if os(iOS) || os(macOS)
import SwiftUI
import EasyStreamCore
import EasyStreamCameraCapture
import EasyStreamUIComponents
import EasyStreamTransport
import AVFoundation

struct CameraSessionLandscapeControlsColumn: View {
    let metrics: CameraSessionLayoutMetrics
    let layout: CameraSessionLayoutKind
    @Binding var showsControls: Bool
    @Bindable var viewModel: CameraSessionViewModel
    @Bindable var intercomService: TeamIntercomService
    let zoomBinding: Binding<Double>
    let exposureBinding: Binding<Float>
    let whiteBalanceBinding: Binding<WhiteBalanceModeOption>

    var body: some View {
        if showsControls || layout != .phone {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    CameraSessionControlsCard(
                        isMuted: $viewModel.isMuted,
                        zoomBinding: zoomBinding,
                        exposureBinding: exposureBinding,
                        whiteBalanceBinding: whiteBalanceBinding,
                        availableLenses: viewModel.imagingState.availableLenses,
                        activeLens: viewModel.imagingState.activeLens,
                        zoomRange: viewModel.imagingState.minZoomFactor...viewModel.imagingState.maxZoomFactor,
                        exposureRange: viewModel.imagingState.minExposureBias...viewModel.imagingState.maxExposureBias,
                        onLensSelected: { viewModel.selectLens($0) }
                    )

                    CameraSessionDirectorCard(
                        directors: viewModel.availableDirectors,
                        selectedDirectorID: viewModel.selectedDirectorID,
                        connectedDirectorID: viewModel.connectedDirectorID,
                        streamState: viewModel.streamState,
                        statusMessage: viewModel.statusMessage,
                        canReconnect: viewModel.canReconnect,
                        isReconnecting: viewModel.isReconnecting,
                        onSelectDirector: { viewModel.selectDirector($0) },
                        onReconnect: { viewModel.reconnect() }
                    )

                    CameraSessionIntercomCard(intercomService: intercomService)
                }
                .padding(.bottom, 8)
            }
            .frame(width: metrics.controlsWidth, alignment: .topLeading)
            .transition(.move(edge: .trailing).combined(with: .opacity))
        } else {
            Color.clear
                .frame(width: metrics.controlsWidth)
        }
    }
}
#endif
