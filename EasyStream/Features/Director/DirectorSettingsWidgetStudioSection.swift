import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorWidgetDraftPreviewCanvas: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
        ZStack {
            Color.black
            DirectorProgramPreviewOverlayView(mediaViewModel: mediaViewModel)
            DirectorProgramStudioHintsOverlay(mediaViewModel: mediaViewModel)
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.yellow.opacity(0.5), lineWidth: 1)
        }
    }
}
