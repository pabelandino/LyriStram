#if os(iOS) || os(macOS)
import SwiftUI
import EasyStreamCore
import EasyStreamCameraCapture
import EasyStreamUIComponents

struct CameraSessionControlsCard: View {
    @Binding var isMuted: Bool
    let zoomBinding: Binding<Double>
    let exposureBinding: Binding<Float>
    let whiteBalanceBinding: Binding<WhiteBalanceModeOption>
    let availableLenses: [AvailableCameraLens]
    let activeLens: CameraLensKind
    let zoomRange: ClosedRange<Double>
    let exposureRange: ClosedRange<Float>
    let onLensSelected: (CameraLensKind) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BroadcastSectionHeader("Controles", systemImage: "slider.horizontal.3")

            CameraClientControlsView(
                isMuted: $isMuted,
                zoomFactor: zoomBinding,
                exposureBias: exposureBinding,
                whiteBalance: whiteBalanceBinding,
                availableLenses: availableLenses,
                activeLens: activeLens,
                zoomRange: zoomRange,
                exposureRange: exposureRange,
                onLensSelected: onLensSelected
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .broadcastPanel(elevated: true)
    }
}
#endif
