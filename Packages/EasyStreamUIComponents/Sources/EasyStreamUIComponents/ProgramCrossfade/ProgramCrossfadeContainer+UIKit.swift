#if canImport(UIKit)
import UIKit
import WebRTC

final class ProgramCrossfadeContainerUIView: UIView, ProgramCrossfadeHost {
    private let blackBackdrop = UIView()
    /// Receives spatial transforms — keeps the Metal view at a stable aspect-fit layout.
    private let programTransformHost = UIView()
    private let takeTransformHost = UIView()
    /// Shared letterbox frame — both slots use the same geometry.
    private let programLetterboxHost = UIView()
    private let takeLetterboxHost = UIView()
    /// Permanent on-air bus — outgoing layer during transitions.
    private let programView = LayoutNeutralRTCMTLVideoView(frame: .zero)
    /// Preview warmup (idle, hidden) and incoming layer during transitions.
    private let takeView = LayoutNeutralRTCMTLVideoView(frame: .zero)

    private var storedProgramSlot: ProgramTransitionSlot?
    private var storedTakeSlot: ProgramTransitionSlot?
    private var incomingOnProgram = false
    private var isTransitioning = false

    var programRenderer: RTCVideoRenderer { programView }
    var outgoingRenderer: RTCVideoRenderer { programView }
    var incomingRenderer: RTCVideoRenderer { takeView }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        clipsToBounds = true
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        blackBackdrop.backgroundColor = .black
        blackBackdrop.isUserInteractionEnabled = false
        blackBackdrop.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blackBackdrop)
        NSLayoutConstraint.activate([
            blackBackdrop.leadingAnchor.constraint(equalTo: leadingAnchor),
            blackBackdrop.trailingAnchor.constraint(equalTo: trailingAnchor),
            blackBackdrop.topAnchor.constraint(equalTo: topAnchor),
            blackBackdrop.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        for host in [programTransformHost, takeTransformHost] {
            host.translatesAutoresizingMaskIntoConstraints = false
            host.isUserInteractionEnabled = false
            host.clipsToBounds = true
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
            letterboxHost.isUserInteractionEnabled = false
            letterboxHost.clipsToBounds = true
            transformHost.addSubview(letterboxHost)
            metalView.translatesAutoresizingMaskIntoConstraints = false
            metalView.videoContentMode = .scaleAspectFit
            metalView.isUserInteractionEnabled = false
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

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
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
                programTransformHost.alpha = 1
                takeTransformHost.alpha = 1
                sendSubviewToBack(blackBackdrop)
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
        programTransformHost.alpha = 1

        resetSlotPresentation(takeLetterboxHost)
        takeTransformHost.isHidden = true

        if !warmingTake {
            ProgramCrossfadeRenderer.clearFrame(in: takeView)
        }

        bringSubviewToFront(programTransformHost)
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
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        programTransformHost.alpha = 0
        CATransaction.commit()
    }

    func completeTransitionHandoff() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        storedProgramSlot = nil
        storedTakeSlot = nil
        incomingOnProgram = false
        resetSlotPresentation(takeLetterboxHost)
        resetSlotPresentation(programLetterboxHost)
        takeTransformHost.isHidden = true
        programTransformHost.isHidden = false
        programTransformHost.alpha = 1
        bringSubviewToFront(programTransformHost)
        CATransaction.commit()
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
        programView.setNeedsLayout()
        takeView.setNeedsLayout()
    }

    private func updateStackOrder() {
        sendSubviewToBack(blackBackdrop)
        if incomingOnProgram {
            bringSubviewToFront(programTransformHost)
            bringSubviewToFront(takeTransformHost)
        } else {
            bringSubviewToFront(takeTransformHost)
            bringSubviewToFront(programTransformHost)
        }
    }

    private func applyStoredSlotsIfNeeded() {
        guard let programSlot = storedProgramSlot,
              let takeSlot = storedTakeSlot,
              bounds.width > 0 else { return }

        applySlot(programSlot, to: programLetterboxHost)
        applySlot(takeSlot, to: takeLetterboxHost)
    }

    private func applySlot(_ slot: ProgramTransitionSlot, to host: UIView) {
        if slot.usesSpatialPresentation {
            ProgramTransitionSlotPresenter.apply(slot, to: host, containerWidth: bounds.width)
            ProgramTransitionSlotPresenter.setOpacity(slot.opacity, on: host)
        } else {
            ProgramTransitionSlotPresenter.reset(host)
            ProgramTransitionSlotPresenter.setOpacity(slot.opacity, on: host)
        }
    }

    private func resetSlotPresentation(_ host: UIView) {
        ProgramTransitionSlotPresenter.reset(host)
        ProgramTransitionSlotPresenter.setOpacity(1, on: host)
    }

    private func clearSlotBuffer(_ view: LayoutNeutralRTCMTLVideoView) {
        ProgramCrossfadeRenderer.clearFrame(in: view)
    }
}
#endif
