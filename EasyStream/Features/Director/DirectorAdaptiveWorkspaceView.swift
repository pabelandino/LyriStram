import SwiftUI
#if os(iOS)
import UIKit
#endif
import EasyStreamCore
import EasyStreamUIComponents
import EasyStreamTransport

/// Open inner display uses three columns. A half-folded inner display puts preview and program above the crease.
struct DirectorAdaptiveWorkspaceView: View {
    let viewModel: DirectorSessionViewModel
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    @Bindable var intercomService: TeamIntercomService
    @Bindable var liveProgramAir: LiveProgramAirStore
    let onLeaveRole: () -> Void
    let onCreateWidget: () -> Void
    let onOpenSettings: () -> Void
    let onOpenMonitor: () -> Void

    @State private var regions = DirectorDisplayRegions()

    /// Unfolded iPhone Duo is a phone with a regular-width inner display. iPad keeps its own header metrics.
    private var alignsColumnHeaders: Bool {
#if os(iOS)
        UIDevice.current.userInterfaceIdiom == .phone
#else
        false
#endif
    }

    var body: some View {
        GeometryReader { proxy in
            let insets = proxy.safeAreaInsets
            let canvas = CGSize(
                width: proxy.size.width + insets.leading + insets.trailing,
                height: proxy.size.height + insets.top + insets.bottom
            )
            let fold = regions.horizontalFold(in: canvas)
            let extraTop = max(0, regions.topCenterOcclusion(in: canvas) - insets.top)
            let extraTrailing = max(0, regions.trailingOcclusion(in: canvas) - insets.trailing)
            let extraBottom = max(0, regions.bottomOcclusion(in: canvas) - insets.bottom)
            Group {
                if let fold {
                    let top = min(
                        max(160, fold.minY - insets.top),
                        max(160, proxy.size.height - fold.height - 180)
                    )
                    DirectorFoldedWorkspaceView(
                        viewModel: viewModel,
                        mediaViewModel: mediaViewModel,
                        intercomService: intercomService,
                        liveProgramAir: liveProgramAir,
                        topHeight: top,
                        foldHeight: fold.height,
                        onLeaveRole: onLeaveRole,
                        onCreateWidget: onCreateWidget,
                        onOpenSettings: onOpenSettings,
                        onOpenMonitor: onOpenMonitor
                    )
                    .environment(\.directorCompactChrome, true)
                } else {
                    DirectorColumnWorkspaceView(
                        viewModel: viewModel,
                        mediaViewModel: mediaViewModel,
                        intercomService: intercomService,
                        liveProgramAir: liveProgramAir,
                        canvasWidth: canvas.width,
                        onLeaveRole: onLeaveRole,
                        onCreateWidget: onCreateWidget,
                        onOpenSettings: onOpenSettings,
                        onOpenMonitor: onOpenMonitor
                    )
                    .environment(\.directorCompactChrome, canvas.width < 1400)
                }
            }
            .padding(.top, extraTop)
            .padding(.bottom, extraBottom + (alignsColumnHeaders ? 24 : 0))
            .padding(.trailing, extraTrailing)
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
        }
        .background {
            ZStack {
                BroadcastTheme.panelBackground
                DirectorReservedRegionReader { regions = $0 }
                DirectorCanvasBackdrop()
            }
            .ignoresSafeArea()
        }
    }
}

/// Fills the window behind the safe area so the Duo status cluster is not a black gap.
struct DirectorCanvasBackdrop: View {
    var body: some View {
#if os(iOS)
        DirectorWindowBackdrop()
            .allowsHitTesting(false)
#else
        Color.clear.allowsHitTesting(false)
#endif
    }
}

#if os(iOS)
private struct DirectorWindowBackdrop: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            uiView.window?.backgroundColor = UIColor(red: 0.06, green: 0.07, blue: 0.09, alpha: 1)
        }
    }
}
#endif
