import EasyStreamCore

/// Maps `SwitchTransitionKind` to effect implementations — single entry point for the renderer.
enum ProgramTransitionEngine {
    static func frame(linearProgress: LinearProgress, kind: SwitchTransitionKind) -> ProgramTransitionFrame {
        let progress = min(max(linearProgress, 0), 1)
        switch kind.presentedKind {
        case .cut:
            return CutTransitionEffect.frame(linearProgress: progress)
        case .dissolve:
            return DissolveTransitionEffect.frame(linearProgress: progress)
        default:
            return DissolveTransitionEffect.frame(linearProgress: progress)
        }
    }
}
