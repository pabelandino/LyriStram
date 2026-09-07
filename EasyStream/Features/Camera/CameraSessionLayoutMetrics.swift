#if os(iOS) || os(macOS)
import SwiftUI
#if os(iOS)
import UIKit
#endif

enum CameraSessionLayoutKind {
    case phone
    case tablet
    case mac

    static var current: CameraSessionLayoutKind {
#if os(macOS)
        .mac
#else
        UIDevice.current.userInterfaceIdiom == .phone ? .phone : .tablet
#endif
    }
}

struct CameraSessionLayoutMetrics {
    let videoWidth: CGFloat
    let videoHeight: CGFloat
    let controlsWidth: CGFloat
    let edgePadding: CGFloat
    let columnSpacing: CGFloat

    init(size: CGSize, layout: CameraSessionLayoutKind) {
        switch layout {
        case .phone:
            edgePadding = 10
            columnSpacing = 10
        case .tablet:
            edgePadding = 18
            columnSpacing = 14
        case .mac:
            edgePadding = 20
            columnSpacing = 16
        }

        let usableWidth = max(0, size.width - edgePadding * 2 - columnSpacing)
        let videoShare: CGFloat
        switch layout {
        case .phone: videoShare = 0.44
        case .tablet: videoShare = 0.50
        case .mac: videoShare = 0.48
        }
        var width = usableWidth * videoShare
        var height = width * 9 / 16

        let maxVideoHeight: CGFloat
        switch layout {
        case .phone: maxVideoHeight = size.height * 0.78
        case .tablet: maxVideoHeight = size.height * 0.72
        case .mac: maxVideoHeight = size.height * 0.68
        }
        if height > maxVideoHeight {
            height = maxVideoHeight
            width = height * 16 / 9
        }

        let minControls: CGFloat
        switch layout {
        case .phone: minControls = 220
        case .tablet: minControls = 280
        case .mac: minControls = 300
        }
        if usableWidth - width < minControls {
            width = max(160, usableWidth - minControls)
            height = width * 9 / 16
        }

        videoWidth = width
        videoHeight = height
        controlsWidth = max(minControls, usableWidth - width)
    }
}
#endif
