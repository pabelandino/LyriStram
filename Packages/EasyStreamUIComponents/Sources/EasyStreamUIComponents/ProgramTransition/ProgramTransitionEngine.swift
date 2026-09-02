import EasyStreamCore

/// Maps `SwitchTransitionKind` to effect implementations — single entry point for the renderer.
enum ProgramTransitionEngine {
    static func frame(linearProgress: LinearProgress, kind: SwitchTransitionKind) -> ProgramTransitionFrame {
        let progress = min(max(linearProgress, 0), 1)
        switch kind {
        case .cut:
            return CutTransitionEffect.frame(linearProgress: progress)
        case .dissolve:
            return DissolveTransitionEffect.frame(linearProgress: progress)
        case .fade:
            return FadeTransitionEffect.frame(linearProgress: progress)
        case .wipe:
            return WipeTransitionEffect.frame(linearProgress: progress)
        case .slide:
            return SlideTransitionEffect.frame(linearProgress: progress)
        case .zoom:
            return ZoomTransitionEffect.frame(linearProgress: progress)
        }
    }
}
