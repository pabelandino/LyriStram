import SwiftUI
import EasyStreamCore
import EasyStreamCameraCapture

public struct CameraClientControlsView: View {
    @Binding var isMuted: Bool
    @Binding var zoomFactor: Double
    @Binding var exposureBias: Float
    @Binding var whiteBalance: WhiteBalanceModeOption
    let availableLenses: [AvailableCameraLens]
    let activeLens: CameraLensKind
    let zoomRange: ClosedRange<Double>
    let exposureRange: ClosedRange<Float>
    let onLensSelected: (CameraLensKind) -> Void

    public init(
        isMuted: Binding<Bool>,
        zoomFactor: Binding<Double>,
        exposureBias: Binding<Float>,
        whiteBalance: Binding<WhiteBalanceModeOption>,
        availableLenses: [AvailableCameraLens],
        activeLens: CameraLensKind,
        zoomRange: ClosedRange<Double>,
        exposureRange: ClosedRange<Float>,
        onLensSelected: @escaping (CameraLensKind) -> Void
    ) {
        _isMuted = isMuted
        _zoomFactor = zoomFactor
        _exposureBias = exposureBias
        _whiteBalance = whiteBalance
        self.availableLenses = availableLenses
        self.activeLens = activeLens
        self.zoomRange = zoomRange
        self.exposureRange = exposureRange
        self.onLensSelected = onLensSelected
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            muteControl
            lensPicker
            zoomControl
            exposureControl
            whiteBalancePicker
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var muteControl: some View {
        Toggle(isOn: $isMuted) {
            Label("Silenciar micrófono", systemImage: isMuted ? "mic.slash.fill" : "mic.fill")
        }
        .toggleStyle(.switch)
    }

    private var lensPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cámara")
                .font(.subheadline.weight(.semibold))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(availableLenses) { lens in
                        Button {
                            onLensSelected(lens.kind)
                        } label: {
                            Text(lensShortLabel(lens))
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(
                                    activeLens == lens.kind ? BroadcastTheme.studioAccent : BroadcastTheme.panelElevated,
                                    in: Capsule()
                                )
                                .overlay(
                                    Capsule().strokeBorder(
                                        activeLens == lens.kind ? BroadcastTheme.studioAccent.opacity(0.6) : BroadcastTheme.panelBorder,
                                        lineWidth: 1
                                    )
                                )
                                .foregroundStyle(activeLens == lens.kind ? Color.white : Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var zoomControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Zoom")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(String(format: "%.1fx", zoomFactor))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $zoomFactor, in: zoomRange)
        }
    }

    private var exposureControl: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Exposición")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(String(format: "%+.1f EV", exposureBias))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(
                value: Binding(
                    get: { Double(exposureBias) },
                    set: { exposureBias = Float($0) }
                ),
                in: Double(exposureRange.lowerBound)...Double(exposureRange.upperBound)
            )
        }
    }

    private var whiteBalancePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Balance de blancos")
                .font(.subheadline.weight(.semibold))
            Picker("Balance de blancos", selection: $whiteBalance) {
                ForEach(WhiteBalanceModeOption.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
#if os(iOS)
            .pickerStyle(.menu)
#else
            .broadcastNativeSegmentedControl()
#endif
        }
    }

    private func lensShortLabel(_ lens: AvailableCameraLens) -> String {
        switch lens.kind {
        case .ultraWide: "Ultra wide"
        case .wide: "Wide"
        case .telephoto: "Tele"
        case .front: "Front"
        }
    }
}
