import SwiftUI
import EasyStreamCore

public struct BroadcastWidgetStudioPanel: View {
    @Binding var configuration: BroadcastWidgetConfiguration
    @Binding var displayName: String
    let templateTitle: String
    let logoURL: URL?
    let isEditingExisting: Bool
    let isLiveOnAir: Bool
    let isEditingPlacement: Bool
    let onEnterPlayMode: () -> Void
    let onEnterLayoutMode: () -> Void
    let onImportLogo: () -> Void
    let onImportLogoFromPhotoLibrary: () -> Void
    let onSave: () -> Void
    let onPreview: () -> Void
    let onGoLive: () -> Void
    let onApplyToLive: () -> Void
    let onRemoveFromLive: () -> Void
    let onClose: () -> Void

    public init(
        configuration: Binding<BroadcastWidgetConfiguration>,
        displayName: Binding<String>,
        templateTitle: String,
        logoURL: URL?,
        isEditingExisting: Bool,
        isLiveOnAir: Bool = false,
        isEditingPlacement: Bool,
        onEnterPlayMode: @escaping () -> Void,
        onEnterLayoutMode: @escaping () -> Void,
        onImportLogo: @escaping () -> Void,
        onImportLogoFromPhotoLibrary: @escaping () -> Void = {},
        onSave: @escaping () -> Void,
        onPreview: @escaping () -> Void,
        onGoLive: @escaping () -> Void,
        onApplyToLive: @escaping () -> Void = {},
        onRemoveFromLive: @escaping () -> Void = {},
        onClose: @escaping () -> Void
    ) {
        self._configuration = configuration
        self._displayName = displayName
        self.templateTitle = templateTitle
        self.logoURL = logoURL
        self.isEditingExisting = isEditingExisting
        self.isLiveOnAir = isLiveOnAir
        self.isEditingPlacement = isEditingPlacement
        self.onEnterPlayMode = onEnterPlayMode
        self.onEnterLayoutMode = onEnterLayoutMode
        self.onImportLogo = onImportLogo
        self.onImportLogoFromPhotoLibrary = onImportLogoFromPhotoLibrary
        self.onSave = onSave
        self.onPreview = onPreview
        self.onGoLive = onGoLive
        self.onApplyToLive = onApplyToLive
        self.onRemoveFromLive = onRemoveFromLive
        self.onClose = onClose
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            if !isEditingExisting { templatePicker }
            templateBadge
            nameField
            templateSpecificFields
            if showsFontSection { fontSection }
            previewModeSection
            actionButtons
        }
        .padding(4)
    }

    private var templateBadge: some View {
        Label(templateTitle, systemImage: configuration.resolvedTemplate.systemImage)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .broadcastGlassPanel(cornerRadius: 10)
    }

    private var templatePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plantilla")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                ForEach(BroadcastWidgetTemplate.mentoTemplates, id: \.self) { template in
                    Button {
                        configuration.template = template
                        configuration.applyTemplateDefaults()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: template.systemImage)
                            Text(template.title)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .broadcastGlassPanel(cornerRadius: 10)
                    .overlay {
                        if configuration.resolvedTemplate == template {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(BroadcastTheme.studioAccent.opacity(0.85), lineWidth: 1.5)
                                .shadow(color: BroadcastTheme.studioAccent.opacity(0.35), radius: 6)
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Widget Studio")
                    .font(.headline)
                Text(isEditingExisting ? "Editando: \(templateTitle)" : "Nuevo widget · elige plantilla")
                    .font(.caption)
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(BroadcastTheme.subtleText)
            }
            .buttonStyle(.plain)
        }
    }

    private var nameField: some View {
        TextField("Nombre en biblioteca", text: $displayName)
            .textFieldStyle(.roundedBorder)
    }

    @ViewBuilder
    private var templateSpecificFields: some View {
        switch configuration.resolvedTemplate {
        case .animatedLogo, .logo:
            BroadcastWidgetStudioLogoFields(
                configuration: $configuration,
                logoURL: logoURL,
                onImportLogo: onImportLogo,
                onImportLogoFromPhotoLibrary: onImportLogoFromPhotoLibrary
            )
        case .ticker, .textBanner:
            BroadcastWidgetStudioTickerFields(configuration: $configuration)
        case .lowerThirdPro, .lowerThird:
            BroadcastWidgetStudioLowerThirdFields(
                configuration: $configuration,
                onImportLogo: onImportLogo,
                onImportLogoFromPhotoLibrary: onImportLogoFromPhotoLibrary
            )
        case .clock:
            BroadcastWidgetStudioClockFields(configuration: $configuration)
        case .countdown:
            BroadcastWidgetStudioCountdownFields(configuration: $configuration)
        }
    }

    private var showsFontSection: Bool {
        switch configuration.resolvedTemplate {
        case .animatedLogo, .logo:
            false
        default:
            false
        }
    }

    private var fontSection: some View {
        EmptyView()
    }

    private var previewModeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vista previa")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            HStack(spacing: 8) {
                Button(action: onEnterPlayMode) {
                    Label("Play", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BroadcastGlowButtonStyle(
                    tint: BroadcastTheme.previewGreen,
                    isProminent: !isEditingPlacement
                ))

                Button(action: onEnterLayoutMode) {
                    Label("Posicionar", systemImage: "arrow.up.left.and.arrow.down.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BroadcastGlowButtonStyle(
                    tint: BroadcastTheme.liveAmber,
                    isProminent: isEditingPlacement
                ))
            }

            Text(isEditingPlacement
                 ? "Modo posicionar: arrastra y redimensiona en el monitor."
                 : "Modo play: animaciones activas, sin agarraderos.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button("Guardar", action: onSave)
                    .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: false))
                Button("Preview", action: onPreview)
                    .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: false))
            }

            if isLiveOnAir {
                Button(action: onApplyToLive) {
                    Label("Aplicar al aire", systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))

                Button(role: .destructive, action: onRemoveFromLive) {
                    Label("Quitar del aire", systemImage: "minus.circle.fill")
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.programRed, isProminent: true))
            } else {
                Button(action: onGoLive) {
                    Label("Agregar al aire", systemImage: "plus.circle.fill")
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.liveAmber, isProminent: true))
            }
        }
    }
}
