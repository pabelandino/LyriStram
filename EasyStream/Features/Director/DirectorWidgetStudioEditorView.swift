import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

/// Standalone widget editor — fixed preview header + scrollable controls (macOS-friendly).
struct DirectorWidgetStudioEditorView: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            previewColumn
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 8)

            Divider().overlay(BroadcastTheme.workspaceDivider)

            controlsColumn
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .broadcastStudioChrome()
    }

    private var previewColumn: some View {
        DirectorInspectorSection("Vista previa del borrador", systemImage: "eye") {
            WidgetStudioDraftPreviewSurface(
                configuration: mediaViewModel.draftWidgetConfiguration,
                displayName: mediaViewModel.draftWidgetDisplayName,
                logoURL: mediaViewModel.editingWidgetResource.flatMap { mediaViewModel.logoURL(for: $0) },
                isPlacementEditing: mediaViewModel.isWidgetPlacementEditing,
                placement: $mediaViewModel.draftWidgetConfiguration.placement
            )
        }
    }

    private var controlsColumn: some View {
        ScrollView(.vertical, showsIndicators: true) {
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
                    onClose: onClose
                )
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Isolated draft preview — narrow inputs avoid library/search invalidation storms.
private struct WidgetStudioDraftPreviewSurface: View {
    let configuration: BroadcastWidgetConfiguration
    let displayName: String
    let logoURL: URL?
    let isPlacementEditing: Bool
    @Binding var placement: BroadcastWidgetPlacement

    var body: some View {
        ZStack {
            Color.black
            PreviewWidgetOverlayView(
                layers: [
                    ProgramFeedWidgetLayer(
                        id: UUID(),
                        configuration: configuration,
                        logoURL: logoURL,
                        isLive: false,
                        isEditing: true
                    )
                ],
                isPlacementEditing: isPlacementEditing,
                editingPlacement: $placement,
                allowsMotion: false
            )
            if isPlacementEditing {
                VStack {
                    Spacer()
                    Text("Arrastra para posicionar · \(displayName)")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.55), in: Capsule())
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(8)
                }
            }
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
