import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorSettingsWidgetStudioSection: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            DirectorInspectorSection("Vista previa del borrador", systemImage: "eye") {
                DirectorWidgetDraftPreviewCanvas(mediaViewModel: mediaViewModel)
            }

            DirectorInspectorSection("Widget Studio", systemImage: "wand.and.stars") {
                BroadcastWidgetStudioPanel(
                    configuration: $mediaViewModel.draftWidgetConfiguration,
                    displayName: $mediaViewModel.draftWidgetDisplayName,
                    templateTitle: mediaViewModel.draftWidgetConfiguration.resolvedTemplate.title,
                    logoURL: mediaViewModel.editingWidgetResource.flatMap { mediaViewModel.logoURL(for: $0) },
                    isEditingExisting: mediaViewModel.isEditingExistingWidget,
                    isLiveOnAir: mediaViewModel.editingWidgetResource.map {
                        mediaViewModel.liveWidgetIDs.contains($0.id)
                    } ?? false,
                    isEditingPlacement: mediaViewModel.isWidgetPlacementEditing,
                    onEnterPlayMode: { mediaViewModel.enterWidgetPlayPreview() },
                    onEnterLayoutMode: { mediaViewModel.enterWidgetLayoutEditing() },
                    onImportLogo: { mediaViewModel.requestWidgetLogoImport() },
                    onImportLogoFromPhotoLibrary: { mediaViewModel.requestWidgetLogoImportFromPhotoLibrary() },
                    onSave: { mediaViewModel.saveDraftWidget() },
                    onPreview: { mediaViewModel.previewDraftWidget() },
                    onGoLive: { mediaViewModel.takeDraftWidgetLive() },
                    onApplyToLive: { mediaViewModel.applyDraftToLiveAir() },
                    onRemoveFromLive: {
                        if let id = mediaViewModel.editingWidgetResource?.id {
                            mediaViewModel.removeWidgetFromLive(id)
                        }
                    },
                    onClose: { mediaViewModel.closeWidgetStudio() }
                )
            }
        }
    }
}

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
