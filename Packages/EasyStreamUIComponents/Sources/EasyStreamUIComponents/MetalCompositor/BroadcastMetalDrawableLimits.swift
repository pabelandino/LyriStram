import CoreGraphics

/// Caps GPU compositor resolution — PROG monitor layout can be large but pixels need not match 1:1.
enum BroadcastMetalDrawableLimits {
    static let maxPixelWidth: CGFloat = 1_280
    static let maxPixelHeight: CGFloat = 720

    static func cappedDrawableSize(bounds: CGSize, scale: CGFloat) -> CGSize {
        guard bounds.width > 0, bounds.height > 0 else { return .zero }
        var width = bounds.width * scale
        var height = bounds.height * scale
        guard width > maxPixelWidth || height > maxPixelHeight else {
            return CGSize(width: width, height: height)
        }
        let downscale = min(maxPixelWidth / width, maxPixelHeight / height)
        width *= downscale
        height *= downscale
        return CGSize(width: width.rounded(), height: height.rounded())
    }
}
