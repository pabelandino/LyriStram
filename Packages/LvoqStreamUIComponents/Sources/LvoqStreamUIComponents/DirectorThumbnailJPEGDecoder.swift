import CoreGraphics
import Foundation
import ImageIO

enum DirectorThumbnailJPEGDecoder {
    static func decode(_ data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }
}
