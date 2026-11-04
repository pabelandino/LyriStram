import SwiftUI

/// Which roles fit the space the app actually has.
/// iPhone Duo’s outer display is compact, like an iPhone. The inner display is regular, like an iPad.
enum AppRoleAvailability {
    case cameraOnly
    case directorAndCamera

    var offersDirector: Bool {
        self == .directorAndCamera
    }

    static func current(horizontalSizeClass: UserInterfaceSizeClass?) -> AppRoleAvailability {
#if os(macOS)
        .directorAndCamera
#else
        horizontalSizeClass == .regular ? .directorAndCamera : .cameraOnly
#endif
    }
}
