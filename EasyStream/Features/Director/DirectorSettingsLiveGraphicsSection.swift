import SwiftUI
import EasyStreamCore
import EasyStreamUIComponents

struct DirectorSettingsLiveGraphicsSection: View {
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
        DirectorInspectorSection("Gráficos al aire", systemImage: "photo.on.rectangle") {
            VStack(alignment: .leading, spacing: 8) {
                if mediaViewModel.isWidgetStudioOpen, !mediaViewModel.isEditingExistingWidget {
                    Label("Preview del widget nuevo", systemImage: "eye")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }

                ForEach(mediaViewModel.liveWidgets) { widget in
                    DirectorLiveWidgetRow(widget: widget, mediaViewModel: mediaViewModel)
                }

                if let fullScreen = mediaViewModel.fullScreenGraphicResource,
                   mediaViewModel.liveFullScreenGraphicID != nil {
                    DirectorLiveFullScreenGraphicRow(
                        resource: fullScreen,
                        onRemove: { mediaViewModel.removeFullScreenFromLive() }
                    )
                }

                if mediaViewModel.isPlaylistPlaying {
                    Button("Siguiente en playlist", action: mediaViewModel.playNextInQueue)
                    Button("Detener playlist", role: .destructive, action: mediaViewModel.stopPlaylistPlayback)
                }

                if !mediaViewModel.liveWidgets.isEmpty || mediaViewModel.liveFullScreenGraphicID != nil {
                    Button("Quitar todos", role: .destructive) {
                        mediaViewModel.clearAllGraphicsFromProgram()
                    }
                }
            }
        }
    }
}

struct DirectorLiveWidgetRow: View {
    let widget: BroadcastResource
    @Bindable var mediaViewModel: BroadcastMediaViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(widget.listLabel)
                    .font(.subheadline.weight(.medium))
                Text(widgetConfigurationLabel)
                    .font(.caption2)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
            Spacer()
            Button("Editar") {
                mediaViewModel.openWidgetStudio(for: widget)
            }
            .buttonStyle(.borderless)
            Button(role: .destructive) {
                mediaViewModel.removeWidgetFromLive(widget.id)
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.borderless)
        }
    }

    private var widgetConfigurationLabel: String {
        mediaViewModel.loadedConfiguration(for: widget)?.resolvedTemplate.title ?? "Widget"
    }
}

struct DirectorLiveFullScreenGraphicRow: View {
    let resource: BroadcastResource
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Text("Pantalla completa: \(resource.listLabel)")
                .font(.subheadline)
            Spacer()
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.borderless)
        }
    }
}
