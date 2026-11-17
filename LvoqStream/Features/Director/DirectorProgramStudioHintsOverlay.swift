import SwiftUI
import LvoqStreamCore
import LvoqStreamUIComponents

/// Studio chrome (preview badge, placement hint) — does not wrap the video bus.
struct DirectorProgramStudioHintsOverlay: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if mediaViewModel.isWidgetStudioOpen,
               mediaViewModel.editingWidgetResource.map({
                   !mediaViewModel.liveWidgetIDs.contains($0.id)
               }) ?? true {
                Text(BundleLocalization.string("PREVIEW"))
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.yellow.opacity(0.9), in: Capsule())
                    .foregroundStyle(.black)
                    .padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }

            if mediaViewModel.isWidgetStudioOpen, !mediaViewModel.isWidgetPlacementEditing {
                Label(BundleLocalization.string("common.play"), systemImage: "play.fill")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(BroadcastTheme.previewGreen.opacity(0.92), in: Capsule())
                    .foregroundStyle(.black)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }

            if mediaViewModel.isWidgetPlacementEditing {
                Text(BundleLocalization.string("studio.overlay.drag_hint"))
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.65), in: Capsule())
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        .allowsHitTesting(false)
    }
}
