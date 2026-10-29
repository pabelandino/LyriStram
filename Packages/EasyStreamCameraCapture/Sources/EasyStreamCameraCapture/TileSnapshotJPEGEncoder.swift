import CoreImage
import CoreVideo
import Foundation
import ImageIO
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum TileSnapshotJPEGEncoder {
    private static let context = CIContext(options: [.cacheIntermediates: false])

    static func encode(pixelBuffer: CVPixelBuffer, maxWidth: Int, quality: CGFloat) -> Data? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        guard width > 0, height > 0 else { return nil }

        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let scale = min(1, CGFloat(maxWidth) / CGFloat(width))
        let scaled = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else {
            return nil
        }

#if canImport(UIKit)
        return UIImage(cgImage: cgImage).jpegData(compressionQuality: quality)
#elseif canImport(AppKit)
        let rep = NSBitmapImageRep(cgImage: cgImage)
        return rep.representation(using: .jpeg, properties: [.compressionFactor: quality])
#else
        return nil
#endif
    }

    static func recompress(jpegData: Data, maxWidth: Int, quality: CGFloat) -> Data? {
        guard let source = CGImageSourceCreateWithData(jpegData as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        let width = cgImage.width
        let height = cgImage.height
        guard width > 0, height > 0 else { return nil }
        let scale = min(1, CGFloat(maxWidth) / CGFloat(width))
        if scale >= 0.999 {
#if canImport(UIKit)
            return UIImage(cgImage: cgImage).jpegData(compressionQuality: quality)
#elseif canImport(AppKit)
            let rep = NSBitmapImageRep(cgImage: cgImage)
            return rep.representation(using: .jpeg, properties: [.compressionFactor: quality])
#else
            return jpegData
#endif
        }
        let scaledWidth = max(1, Int((CGFloat(width) * scale).rounded()))
        let scaledHeight = max(1, Int((CGFloat(height) * scale).rounded()))
        guard let context = CGContext(
            data: nil,
            width: scaledWidth,
            height: scaledHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        context.interpolationQuality = .medium
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))
        guard let scaledImage = context.makeImage() else { return nil }
#if canImport(UIKit)
        return UIImage(cgImage: scaledImage).jpegData(compressionQuality: quality)
#elseif canImport(AppKit)
        let rep = NSBitmapImageRep(cgImage: scaledImage)
        return rep.representation(using: .jpeg, properties: [.compressionFactor: quality])
#else
        return jpegData
#endif
    }
}
