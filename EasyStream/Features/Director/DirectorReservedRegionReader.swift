import SwiftUI

/// Fold and camera regions reported by the window, in the reader view's coordinates.
struct DirectorDisplayRegions: Equatable {
    var divisions: [CGRect] = []
    var occlusions: [CGRect] = []

    /// Horizontal crease of a half-folded inner display. Content stays above and below it.
    func horizontalFold(in size: CGSize) -> CGRect? {
        divisions.first { rect in
            rect.width > size.width * 0.55
                && rect.height > 8
                && rect.height < size.height * 0.45
                && rect.minY > 24
                && rect.maxY < size.height - 24
        }
    }

    func trailingOcclusion(in size: CGSize) -> CGFloat {
        occlusions
            .filter { $0.minX > size.width * 0.62 }
            .map(\.width)
            .max() ?? 0
    }

    /// Chin or home indicator that sits on the bottom edge and clips the take bar.
    func bottomOcclusion(in size: CGSize) -> CGFloat {
        occlusions
            .filter { $0.minY > size.height * 0.72 }
            .map { size.height - $0.minY }
            .max() ?? 0
    }

    /// Inner-camera housing along the top center. Side columns clear it; the middle one does not.
    func topCenterOcclusion(in size: CGSize) -> CGFloat {
        occlusions
            .filter { rect in
                rect.minY < size.height * 0.25
                    && rect.midX > size.width * 0.2
                    && rect.midX < size.width * 0.8
                    && rect.width < size.width * 0.75
            }
            .map(\.maxY)
            .max() ?? 0
    }
}

/// Reads iPhone Duo reserved regions. The fold is a division; the camera and status cluster are occlusions.
struct DirectorReservedRegionReader: View {
    var onChange: (DirectorDisplayRegions) -> Void

    var body: some View {
#if os(iOS)
        DirectorReservedRegionProbe(onChange: onChange)
            .allowsHitTesting(false)
#else
        Color.clear
            .allowsHitTesting(false)
            .onAppear { onChange(DirectorDisplayRegions()) }
#endif
    }
}

#if os(iOS)
import UIKit

private struct DirectorReservedRegionProbe: UIViewRepresentable {
    var onChange: (DirectorDisplayRegions) -> Void

    func makeUIView(context: Context) -> ProbeView {
        let view = ProbeView()
        view.onChange = onChange
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: ProbeView, context: Context) {
        uiView.onChange = onChange
        uiView.publishIfNeeded()
    }
}

private final class ProbeView: UIView {
    var onChange: ((DirectorDisplayRegions) -> Void)?
    private var last = DirectorDisplayRegions()

    override func layoutSubviews() {
        super.layoutSubviews()
        publishIfNeeded()
    }

    func publishIfNeeded() {
        let next = readRegions()
        guard next != last else { return }
        last = next
        let callback = onChange
        DispatchQueue.main.async {
            callback?(next)
        }
    }

    private static func quantized(_ rect: CGRect) -> CGRect {
        CGRect(
            x: rect.minX.rounded(),
            y: rect.minY.rounded(),
            width: rect.width.rounded(),
            height: rect.height.rounded()
        )
    }

    private func readRegions() -> DirectorDisplayRegions {
        guard #available(iOS 27.1, *) else { return DirectorDisplayRegions() }
        let divisions = reservedRegions(kind: .division).filter(\.isActive).map { Self.quantized($0.frame) }
        let occlusions = reservedRegions(kind: .occlusion).filter(\.isActive).map { Self.quantized($0.frame) }
        return DirectorDisplayRegions(divisions: divisions, occlusions: occlusions)
    }
}
#endif
