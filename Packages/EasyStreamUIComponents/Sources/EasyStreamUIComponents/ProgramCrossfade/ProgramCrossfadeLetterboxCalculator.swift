import CoreGraphics
import WebRTC

/// Shared aspect-fit rect so both program slots render at identical letterbox geometry.
enum ProgramCrossfadeLetterboxCalculator {
    static let defaultContentAspect: CGFloat = 16.0 / 9.0

    static func letterboxRect(in containerSize: CGSize, contentAspect: CGFloat) -> CGRect {
        guard containerSize.width > 0, containerSize.height > 0, contentAspect > 0 else {
            return .zero
        }

        let containerAspect = containerSize.width / containerSize.height
        if containerAspect > contentAspect {
            let height = containerSize.height
            let width = height * contentAspect
            let x = (containerSize.width - width) * 0.5
            return CGRect(x: x, y: 0, width: width, height: height)
        }

        let width = containerSize.width
        let height = width / contentAspect
        let y = (containerSize.height - height) * 0.5
        return CGRect(x: 0, y: y, width: width, height: height)
    }
}

final class ProgramCrossfadeLetterboxSizeDelegate: NSObject, RTCVideoViewDelegate {
    var onVideoSizeChanged: (@MainActor (CGSize) -> Void)?

    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        Task { @MainActor [onVideoSizeChanged] in
            onVideoSizeChanged?(size)
        }
    }
}
