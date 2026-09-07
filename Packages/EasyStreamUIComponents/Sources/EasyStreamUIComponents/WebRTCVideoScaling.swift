import CoreGraphics

/// Computes Metal view frames — macOS `RTCMTLNSVideoView` has no `videoContentMode` property.
enum WebRTCVideoScaling {
    static let defaultAspect: CGFloat = 16.0 / 9.0

    static func displayRect(
        videoSize: CGSize,
        containerSize: CGSize,
        mode: WebRTCVideoContentMode
    ) -> CGRect {
        guard containerSize.width > 0, containerSize.height > 0 else { return .zero }

        let contentAspect: CGFloat
        if videoSize.width > 1, videoSize.height > 1 {
            contentAspect = videoSize.width / videoSize.height
        } else {
            contentAspect = defaultAspect
        }

        switch mode {
        case .aspectFit:
            return ProgramCrossfadeLetterboxCalculator.letterboxRect(
                in: containerSize,
                contentAspect: contentAspect
            )
        case .aspectFill:
            return CGRect(origin: .zero, size: containerSize)
        }
    }
}
