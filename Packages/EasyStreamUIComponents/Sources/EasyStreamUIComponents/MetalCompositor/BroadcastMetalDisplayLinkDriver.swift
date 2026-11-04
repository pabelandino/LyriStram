import Foundation
import QuartzCore
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import CoreVideo
#endif

/// Vsync clock for the program picture. The callback stays off the main thread on macOS.
/// Drawing is scheduled by the compositor only when a new frame exists, so menus and
/// windows keep the main run loop.
final class BroadcastMetalDisplayLinkDriver: @unchecked Sendable {
    var preferredFramesPerSecond: Int = 60
    var onFrame: (() -> Void)?

#if canImport(UIKit)
    private var displayLink: CADisplayLink?
#elseif canImport(AppKit)
    private var displayLink: CVDisplayLink?
#endif

    func start() {
        stop()

#if canImport(UIKit)
        let link = CADisplayLink(target: self, selector: #selector(tickUIKit))
        if #available(iOS 15.0, *) {
            link.preferredFrameRateRange = CAFrameRateRange(
                minimum: Float(preferredFramesPerSecond),
                maximum: Float(preferredFramesPerSecond),
                preferred: Float(preferredFramesPerSecond)
            )
        } else {
            link.preferredFramesPerSecond = preferredFramesPerSecond
        }
        link.add(to: .main, forMode: .common)
        displayLink = link
#elseif canImport(AppKit)
        var link: CVDisplayLink?
        guard CVDisplayLinkCreateWithActiveCGDisplays(&link) == kCVReturnSuccess,
              let link else { return }
        displayLink = link
        let callback: CVDisplayLinkOutputCallback = { _, _, _, _, _, userInfo in
            guard let userInfo else { return kCVReturnSuccess }
            let driver = Unmanaged<BroadcastMetalDisplayLinkDriver>
                .fromOpaque(userInfo)
                .takeUnretainedValue()
            driver.onFrame?()
            return kCVReturnSuccess
        }
        CVDisplayLinkSetOutputCallback(
            link,
            callback,
            Unmanaged.passUnretained(self).toOpaque()
        )
        CVDisplayLinkStart(link)
#endif
    }

    func stop() {
#if canImport(UIKit)
        displayLink?.invalidate()
        displayLink = nil
#elseif canImport(AppKit)
        if let displayLink {
            CVDisplayLinkStop(displayLink)
        }
        displayLink = nil
#endif
    }

#if canImport(UIKit)
    @objc private func tickUIKit() {
        onFrame?()
    }
#endif

    deinit {
        stop()
    }
}
