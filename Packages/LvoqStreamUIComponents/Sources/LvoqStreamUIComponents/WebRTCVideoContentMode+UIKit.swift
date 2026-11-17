#if canImport(UIKit)
import UIKit

extension WebRTCVideoContentMode {
    var uiMetalMode: UIView.ContentMode {
        switch self {
        case .aspectFit: .scaleAspectFit
        case .aspectFill: .scaleAspectFill
        }
    }
}
#endif
