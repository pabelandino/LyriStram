import SwiftUI
import ImageIO
import CoreGraphics
import EasyStreamCore

/// Apple / Android mark for the dark director lists. The source PNGs are black, so they are painted white here.
public struct CameraPlatformBrandIcon: View {
    let platform: DevicePlatform
    var size: CGFloat = 16

    public init(platform: DevicePlatform, size: CGFloat = 16, tint: Color = .white) {
        self.platform = platform
        self.size = size
        _ = tint
    }

    public var body: some View {
        if let assetName, let cgImage = WhitePlatformArtwork.image(named: assetName) {
            Image(decorative: cgImage, scale: 1)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: size, height: size)
                .accessibilityHidden(true)
        } else if platform == .atem {
            Text("ATEM")
                .font(.system(size: max(8, size * 0.45), weight: .heavy))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: size)
                .accessibilityHidden(true)
        }
    }

    private var assetName: String? {
        switch platform {
        case .iPhone, .iPad, .mac:
            return "PlatformApple"
        case .android:
            return "PlatformAndroid"
        case .atem, .unknown:
            return nil
        }
    }
}

@MainActor
private enum WhitePlatformArtwork {
    private static var cache: [String: CGImage] = [:]

    static func image(named name: String) -> CGImage? {
        if let cached = cache[name] {
            return cached
        }
        guard let source = load(named: name), let white = paintWhite(source) else {
            return nil
        }
        cache[name] = white
        return white
    }

    private static func load(named name: String) -> CGImage? {
        guard
            let url = Bundle.module.url(forResource: name, withExtension: "png"),
            let source = CGImageSourceCreateWithURL(url as CFURL, nil)
        else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    /// Keeps the logo shape and replaces every opaque pixel with white.
    private static func paintWhite(_ source: CGImage) -> CGImage? {
        let width = source.width
        let height = source.height
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(source, in: rect)
        context.setBlendMode(.sourceIn)
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(rect)
        return context.makeImage()
    }
}
