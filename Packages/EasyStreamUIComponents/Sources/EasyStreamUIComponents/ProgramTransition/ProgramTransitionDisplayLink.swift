import Foundation
import QuartzCore
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
import CoreVideo
#endif

/// Drives program transition progress from the display refresh rate instead of Task.sleep loops.
@MainActor
public enum ProgramTransitionDisplayLink {
    public static func animate(
        duration: TimeInterval,
        preferredFramesPerSecond: Int,
        update: @escaping (Double) -> Void
    ) async {
        guard duration > 0 else {
            update(1)
            return
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let driver = Driver(
                duration: duration,
                preferredFramesPerSecond: preferredFramesPerSecond,
                update: update,
                completion: { continuation.resume() }
            )
            driver.start()
        }
    }

    @MainActor
    private final class Driver {
        private let duration: TimeInterval
        private let preferredFramesPerSecond: Int
        private let update: (Double) -> Void
        private let completion: () -> Void
        private var startedAt: CFTimeInterval = 0

#if canImport(UIKit)
        private var displayLink: CADisplayLink?
#elseif canImport(AppKit)
        private var displayLink: CVDisplayLink?
#endif

        init(
            duration: TimeInterval,
            preferredFramesPerSecond: Int,
            update: @escaping (Double) -> Void,
            completion: @escaping () -> Void
        ) {
            self.duration = duration
            self.preferredFramesPerSecond = preferredFramesPerSecond
            self.update = update
            self.completion = completion
        }

        func start() {
            startedAt = CACurrentMediaTime()
            update(0)

#if canImport(UIKit)
            let link = CADisplayLink(target: self, selector: #selector(stepUIKit))
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
            CVDisplayLinkCreateWithActiveCGDisplays(&link)
            guard let link else {
                finish(at: 1)
                return
            }
            displayLink = link
            let callback: CVDisplayLinkOutputCallback = { _, _, _, _, _, userInfo in
                let driver = Unmanaged<Driver>.fromOpaque(userInfo!).takeUnretainedValue()
                DispatchQueue.main.async {
                    driver.stepAppKit()
                }
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

#if canImport(UIKit)
        @objc private func stepUIKit() {
            stepAppKit()
        }
#endif

        private func stepAppKit() {
            let elapsed = CACurrentMediaTime() - startedAt
            let progress = min(max(elapsed / duration, 0), 1)
            update(progress)
            if progress >= 1 {
                finish(at: 1)
            }
        }

        private func finish(at progress: Double) {
            update(progress)
            stop()
            completion()
        }

        private func stop() {
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
    }
}
