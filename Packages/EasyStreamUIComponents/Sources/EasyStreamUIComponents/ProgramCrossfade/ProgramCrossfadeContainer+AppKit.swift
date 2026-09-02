#if canImport(AppKit)
import AppKit
import WebRTC

final class ProgramCrossfadeContainerNSView: NSView, ProgramCrossfadeHost {
    private let blackBackdrop = NSView()
    private let programTransformHost = NSView()
    private let takeTransformHost = NSView()
    private let programLetterboxHost = NSView()
    private let takeLetterboxHost = NSView()
    private let programView = LayoutNeutralRTCMTLNSVideoView(frame: .zero)
    private let takeView = LayoutNeutralRTCMTLNSVideoView(frame: .zero)

    private var storedProgramSlot: ProgramTransitionSlot?
    private var storedTakeSlot: ProgramTransitionSlot?
    private var incomingOnProgram = false
    private var isTransitioning = false

    var programRenderer: RTCVideoRenderer { programView }
    var outgoingRenderer: RTCVideoRenderer { programView }
    var incomingRenderer: RTCVideoRenderer { takeView }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        clipsToBounds = true
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        blackBackdrop.wantsLayer = true
        blackBackdrop.layer?.backgroundColor = NSColor.black.cgColor
        blackBackdrop.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blackBackdrop)
        NSLayoutConstraint.activate([
            blackBackdrop.leadingAnchor.constraint(equalTo: leadingAnchor),
            blackBackdrop.trailingAnchor.constraint(equalTo: trailingAnchor),
            blackBackdrop.topAnchor.constraint(equalTo: topAnchor),
            blackBackdrop.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        for host in [programTransformHost, takeTransformHost] {
            host.wantsLayer = true
            host.layer?.masksToBounds = true
            host.translatesAutoresizingMaskIntoConstraints = false
            addSubview(host)
            NSLayoutConstraint.activate([
                host.leadingAnchor.constraint(equalTo: leadingAnchor),
                host.trailingAnchor.constraint(equalTo: trailingAnchor),
                host.topAnchor.constraint(equalTo: topAnchor),
                host.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }

        for (metalView, letterboxHost, transformHost) in [
            (programView, programLetterboxHost, programTransformHost),
            (takeView, takeLetterboxHost, takeTransformHost),
        ] {
            letterboxHost.wantsLayer = true
            letterboxHost.layer?.masksToBounds = true
            transformHost.addSubview(letterboxHost)
            metalView.wantsLayer = true
            metalView.layer?.masksToBounds = true
            metalView.translatesAutoresizingMaskIntoConstraints = false
            letterboxHost.addSubview(metalView)
            NSLayoutConstraint.activate([
                metalView.leadingAnchor.constraint(equalTo: letterboxHost.leadingAnchor),
                metalView.trailingAnchor.constraint(equalTo: letterboxHost.trailingAnchor),
                metalView.topAnchor.constraint(equalTo: letterboxHost.topAnchor),
                metalView.bottomAnchor.constraint(equalTo: letterboxHost.bottomAnchor),
            ])
        }

        enterIdleProgramMode(preservingProgramPresentation: false, warmingTake: false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }

    override func layout() {
        super.layout()
        applyLetterboxLayout()
        if isTransitioning {
            applyStoredSlotsIfNeeded()
        }
    }

    func setCrossfadePresentationMode(idleProgram: Bool, transitioning: Bool, warmingTake: Bool) {
        _ = idleProgram
        _ = warmingTake

        if transitioning {
            let isBeginning = !isTransitioning
            isTransitioning = true
            if isBeginning {
                programTransformHost.isHidden = false
                takeTransformHost.isHidden = true
                programTransformHost.alphaValue = 1
                takeTransformHost.alphaValue = 1
            }
            applyLetterboxLayout()
        }
    }

    func enterIdleProgramMode(preservingProgramPresentation: Bool, warmingTake: Bool) {
        isTransitioning = false
        storedProgramSlot = nil
        storedTakeSlot = nil
        incomingOnProgram = false

        if !preservingProgramPresentation {
            resetSlotPresentation(programLetterboxHost)
        }
        programTransformHost.isHidden = false
        programTransformHost.alphaValue = 1

        resetSlotPresentation(takeLetterboxHost)
        takeTransformHost.isHidden = true

        if !warmingTake {
            ProgramCrossfadeRenderer.clearFrame(in: takeView)
        }

        applyLetterboxLayout()
    }

    func applyCrossfadeSlots(
        programSlot: ProgramTransitionSlot,
        takeSlot: ProgramTransitionSlot,
        incomingOnProgram: Bool
    ) {
        storedProgramSlot = programSlot
        storedTakeSlot = takeSlot
        self.incomingOnProgram = incomingOnProgram
        applyStoredSlotsIfNeeded()
        updateStackOrder()
    }

    func revealTakeLayer() {
        takeTransformHost.isHidden = false
        updateStackOrder()
    }

    func beginTransitionHandoff() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0
            context.allowsImplicitAnimation = false
            programTransformHost.alphaValue = 0
        }
    }

    func completeTransitionHandoff() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0
            context.allowsImplicitAnimation = false
            storedProgramSlot = nil
            storedTakeSlot = nil
            incomingOnProgram = false
            resetSlotPresentation(takeLetterboxHost)
            resetSlotPresentation(programLetterboxHost)
            takeTransformHost.isHidden = true
            programTransformHost.isHidden = false
            programTransformHost.alphaValue = 1
        }
    }

    func finalizeTransitionHandoff() {
        completeTransitionHandoff()
    }

    func resetTransitionSlotPresentation() {
        storedProgramSlot = nil
        storedTakeSlot = nil
        incomingOnProgram = false
        resetSlotPresentation(takeLetterboxHost)
        resetSlotPresentation(programLetterboxHost)
    }

    func resetCrossfadePresentation() {
        resetTransitionSlotPresentation()
        clearSlotBuffer(takeView)
        clearSlotBuffer(programView)
    }

    private func applyLetterboxLayout() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        programLetterboxHost.frame = bounds
        takeLetterboxHost.frame = bounds
        programView.needsLayout = true
        takeView.needsLayout = true
    }

    private func updateStackOrder() {
        guard programTransformHost.superview === self,
              takeTransformHost.superview === self else { return }
        if incomingOnProgram {
            addSubview(takeTransformHost, positioned: .above, relativeTo: programTransformHost)
        } else {
            addSubview(programTransformHost, positioned: .above, relativeTo: takeTransformHost)
        }
    }

    private func applyStoredSlotsIfNeeded() {
        guard let programSlot = storedProgramSlot,
              let takeSlot = storedTakeSlot,
              bounds.width > 0 else { return }

        applySlot(programSlot, to: programLetterboxHost)
        applySlot(takeSlot, to: takeLetterboxHost)
    }

    private func applySlot(_ slot: ProgramTransitionSlot, to host: NSView) {
        if slot.usesSpatialPresentation {
            ProgramTransitionSlotPresenter.apply(slot, to: host, containerWidth: bounds.width)
            ProgramTransitionSlotPresenter.setOpacity(slot.opacity, on: host)
        } else {
            ProgramTransitionSlotPresenter.reset(host)
            ProgramTransitionSlotPresenter.setOpacity(slot.opacity, on: host)
        }
    }

    private func resetSlotPresentation(_ host: NSView) {
        ProgramTransitionSlotPresenter.reset(host)
        ProgramTransitionSlotPresenter.setOpacity(1, on: host)
    }

    private func clearSlotBuffer(_ view: LayoutNeutralRTCMTLNSVideoView) {
        ProgramCrossfadeRenderer.clearFrame(in: view)
    }
}
#endif
