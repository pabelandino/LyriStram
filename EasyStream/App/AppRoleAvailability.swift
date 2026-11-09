import SwiftUI
#if os(iOS)
import UIKit
#endif

/// Which roles fit the space the app actually has.
/// A regular iPhone is camera-only. Director on a phone is the unfolded iPhone Duo inner display.
/// iPad and Mac always offer director. The Duo cover display stays camera-only.
enum AppRoleAvailability {
    case cameraOnly
    case directorAndCamera

    var offersDirector: Bool {
        self == .directorAndCamera
    }

    static func current(horizontalSizeClass: UserInterfaceSizeClass?) -> AppRoleAvailability {
#if os(macOS)
        .directorAndCamera
#elseif os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .directorAndCamera
        }
        if UIDevice.current.userInterfaceIdiom == .phone,
           horizontalSizeClass == .regular,
           isUnfoldedIPhoneDuo {
            return .directorAndCamera
        }
        return .cameraOnly
#else
        .cameraOnly
#endif
    }

#if os(iOS)
    /// Unfolded inner canvas is closer to 4:3. A single iPhone, including Pro Max in landscape, stays near 19.5:9.
    private static var isUnfoldedIPhoneDuo: Bool {
        let pixels = UIScreen.main.nativeBounds
        let longSide = max(pixels.width, pixels.height)
        let shortSide = min(pixels.width, pixels.height)
        guard shortSide > 1400, longSide > 0 else { return false }
        return longSide / shortSide < 1.75
    }
#endif
}
