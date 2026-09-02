import EasyStreamCore

/// One transition style — add future effects by conforming and registering in `ProgramTransitionEngine`.
protocol ProgramTransitionEffect: Sendable {
    static var kind: SwitchTransitionKind { get }
    static func frame(linearProgress: LinearProgress) -> ProgramTransitionFrame
}

enum CutTransitionEffect: ProgramTransitionEffect {
    static let kind: SwitchTransitionKind = .cut

    static func frame(linearProgress: LinearProgress) -> ProgramTransitionFrame {
        _ = linearProgress
        return .cutIncoming
    }
}

enum DissolveTransitionEffect: ProgramTransitionEffect {
    static let kind: SwitchTransitionKind = .dissolve

    static func frame(linearProgress: LinearProgress) -> ProgramTransitionFrame {
        let t = TransitionCurveProfile.opacity.evaluate(linearProgress)
        let outgoingOpacity = 1 - t
        let incomingOpacity = t
        return ProgramTransitionFrame(
            outgoing: .visible(opacity: outgoingOpacity),
            incoming: .visible(opacity: incomingOpacity),
            lifecycle: ProgramTransitionLifecycleRules.opacityCrossfade(
                linearProgress: linearProgress,
                outgoingOpacity: outgoingOpacity,
                incomingOpacity: incomingOpacity
            ),
            presentationMode: .opacityOnly
        )
    }
}

enum FadeTransitionEffect: ProgramTransitionEffect {
    static let kind: SwitchTransitionKind = .fade

    static func frame(linearProgress: LinearProgress) -> ProgramTransitionFrame {
        let (outgoingOpacity, incomingOpacity) = fadeThroughBlack(linearProgress)
        return ProgramTransitionFrame(
            outgoing: .visible(opacity: outgoingOpacity),
            incoming: .visible(opacity: incomingOpacity),
            lifecycle: ProgramTransitionLifecycleRules.opacityCrossfade(
                linearProgress: linearProgress,
                outgoingOpacity: outgoingOpacity,
                incomingOpacity: incomingOpacity
            ),
            presentationMode: .opacityOnly
        )
    }

    private static func fadeThroughBlack(_ progress: LinearProgress) -> (outgoing: Double, incoming: Double) {
        let hold = 0.1
        let fadeOutEnd = 0.5 - hold / 2
        let fadeInStart = 0.5 + hold / 2
        let curve = TransitionCurveProfile.opacity

        let outgoing: Double
        if progress <= fadeOutEnd {
            outgoing = 1 - curve.evaluate(progress / fadeOutEnd)
        } else {
            outgoing = 0
        }

        let incoming: Double
        if progress >= fadeInStart {
            incoming = curve.evaluate((progress - fadeInStart) / (1 - fadeInStart))
        } else {
            incoming = 0
        }

        return (outgoing, incoming)
    }
}

enum WipeTransitionEffect: ProgramTransitionEffect {
    static let kind: SwitchTransitionKind = .wipe

    static func frame(linearProgress: LinearProgress) -> ProgramTransitionFrame {
        let motion = TransitionCurveProfile.spatial.evaluate(linearProgress)
        return ProgramTransitionFrame(
            outgoing: .visible(),
            incoming: .visible(reveal: motion),
            lifecycle: ProgramTransitionLifecycleRules.spatial(
                linearProgress: linearProgress,
                motionProgress: motion
            ),
            presentationMode: .spatial
        )
    }
}

enum SlideTransitionEffect: ProgramTransitionEffect {
    static let kind: SwitchTransitionKind = .slide

    static func frame(linearProgress: LinearProgress) -> ProgramTransitionFrame {
        let motion = TransitionCurveProfile.spatial.evaluate(linearProgress)
        return ProgramTransitionFrame(
            outgoing: .visible(offsetX: -motion),
            incoming: .visible(offsetX: 1 - motion),
            lifecycle: ProgramTransitionLifecycleRules.spatial(
                linearProgress: linearProgress,
                motionProgress: motion,
                attachThreshold: 0
            ),
            presentationMode: .spatial
        )
    }
}

enum ZoomTransitionEffect: ProgramTransitionEffect {
    static let kind: SwitchTransitionKind = .zoom
    private static let scaleDelta = 0.1

    static func frame(linearProgress: LinearProgress) -> ProgramTransitionFrame {
        let t = TransitionCurveProfile.zoomBlend.evaluate(linearProgress)
        let outgoingOpacity = 1 - t
        let incomingOpacity = t
        return ProgramTransitionFrame(
            outgoing: .visible(
                opacity: outgoingOpacity,
                scale: 1 - (scaleDelta * t)
            ),
            incoming: .visible(
                opacity: incomingOpacity,
                scale: 1 + (scaleDelta * (1 - t))
            ),
            lifecycle: ProgramTransitionLifecycleRules.opacityCrossfade(
                linearProgress: linearProgress,
                outgoingOpacity: outgoingOpacity,
                incomingOpacity: incomingOpacity
            ),
            presentationMode: .spatial
        )
    }
}
