import SwiftUI
import UniformTypeIdentifiers
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
            logoFields
        case .ticker, .textBanner:
            tickerFields
        case .lowerThirdPro, .lowerThird:
            lowerThirdFields
        case .clock:
            clockFields
        case .countdown:
            countdownFields
        }
    }

    private var logoFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onImportLogo) {
                Label(logoURL == nil ? "Importar logo PNG" : "Cambiar logo PNG", systemImage: "photo.badge.plus")
            }
            .buttonStyle(.bordered)

            Picker("Animación", selection: $configuration.logoAnimation) {
                ForEach(BroadcastLogoAnimation.allCases, id: \.self) { animation in
                    Text(animation.displayName).tag(animation)
                }
            }
#if os(macOS)
            .pickerStyle(.menu)
#endif

            placementSizeControls

            Stepper(
                "Velocidad: \(String(format: "%.1fx", configuration.animationSpeed))",
                value: $configuration.animationSpeed,
                in: 0.25...3,
                step: 0.25
            )

            Text("Las animaciones corren en ráfagas con pausa (idle) entre ciclos.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
        }
    }

    private var placementSizeControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tamaño en pantalla")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            Stepper(
                "Ancho: \(Int(configuration.placement.widthFraction * 100))%",
                value: $configuration.placement.widthFraction,
                in: 0.05...1,
                step: 0.01
            )

            Stepper(
                "Alto: \(Int(configuration.placement.heightFraction * 100))%",
                value: $configuration.placement.heightFraction,
                in: 0.05...1,
                step: 0.01
            )

            Text("También puedes arrastrar y redimensionar en el preview del programa.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
        }
    }

    private var tickerFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Texto del ticker", text: $configuration.tickerText, prompt: Text("Escribe el texto con espacios"))
                .textFieldStyle(.roundedBorder)
#if os(macOS)
                .disableAutocorrection(true)
#endif

            HStack {
                Text("Color del texto")
                    .font(.caption)
                Spacer()
                BroadcastHexColorWell(
                    optionalHex: $configuration.tickerTextColorHex,
                    supportsOpacity: false,
                    fallback: "FFFFFF"
                )
            }

            Toggle("Fondo con gradiente", isOn: useTickerGradientBinding)

            if configuration.resolvedUseTickerGradient {
                gradientColorRow("Inicio", hex: tickerGradientStartBinding)
                gradientColorRow("Fin", hex: tickerGradientEndBinding)
            } else {
                HStack {
                    Text("Color de fondo")
                        .font(.caption)
                    Spacer()
                    BroadcastHexColorWell(
                        optionalHex: $configuration.tickerBackgroundHex,
                        supportsOpacity: true,
                        fallback: "CC000000"
                    )
                }
            }

            tickerPlacementControls

            Stepper(
                "Velocidad: \(Int(configuration.tickerSpeed)) pt/s",
                value: $configuration.tickerSpeed,
                in: 30...200,
                step: 5
            )
            fontControls(titleLabel: "Fuente del ticker", includeSubtitle: false)
        }
    }

    private var tickerPlacementControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tamaño y posición")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)

            Stepper(
                "Ancho: \(Int(configuration.placement.widthFraction * 100))%",
                value: $configuration.placement.widthFraction,
                in: 0.2...1,
                step: 0.01
            )

            Stepper(
                "Alto del fondo: \(Int(configuration.placement.heightFraction * 100))%",
                value: $configuration.placement.heightFraction,
                in: 0.04...0.4,
                step: 0.01
            )

            Text("Usa «Mover y redimensionar» para arrastrar el ticker en el preview.")
                .font(.caption2)
                .foregroundStyle(BroadcastTheme.subtleText)
        }
    }

    private var lowerThirdFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Título", text: $configuration.title)
                .textFieldStyle(.roundedBorder)
            TextField("Subtítulo", text: Binding(
                get: { configuration.subtitle ?? "" },
                set: { configuration.subtitle = $0.isEmpty ? nil : $0 }
            ))
            .textFieldStyle(.roundedBorder)

            colorWellRow("Color título", optionalHex: $configuration.titleColorHex, fallback: "FFFFFF")
            colorWellRow("Color subtítulo", optionalHex: $configuration.subtitleColorHex, fallback: "FFFFFFE6")

            Toggle("Fondo con gradiente", isOn: useLowerThirdGradientBinding)

            if configuration.resolvedUseLowerThirdGradient {
                gradientColorRow("Gradiente inicio", hex: lowerThirdGradientStartBinding)
                gradientColorRow("Gradiente fin", hex: lowerThirdGradientEndBinding)
            } else {
                colorWellRow("Color fondo", optionalHex: $configuration.accentColorHex, fallback: "007AFF")
            }

            Button(action: onImportLogo) {
                Label("Logo PNG (opcional)", systemImage: "photo")
            }
            .buttonStyle(.bordered)

            Toggle("Secuencia automática", isOn: $configuration.autoPlaySequence)
            Stepper(
                "Visible: \(Int(configuration.holdDurationSeconds)) s",
                value: $configuration.holdDurationSeconds,
                in: 2...30
            )
            fontControls(titleLabel: "Fuente título", includeSubtitle: true)
        }
    }

    private var clockFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Mostrar segundos", isOn: $configuration.clockShowsSeconds)
            Toggle("Mostrar fecha", isOn: $configuration.clockShowsDate)
            Toggle("Formato 24 h", isOn: $configuration.clockUse24Hour)
            fontControls(titleLabel: "Fuente reloj", includeSubtitle: configuration.clockShowsDate)
        }
    }

    private var countdownFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Color")
                    .font(.caption)
                TextField("Hex", text: Binding(
                    get: { configuration.accentColorHex ?? "007AFF" },
                    set: { configuration.accentColorHex = $0 }
                ))
                .textFieldStyle(.roundedBorder)
            }
            Stepper(
                "Segundos: \(configuration.countdownSeconds)",
                value: $configuration.countdownSeconds,
                in: 5...3600,
                step: 5
            )
            Picker("Animación", selection: $configuration.countdownAnimation) {
                ForEach(BroadcastCountdownAnimation.allCases, id: \.self) { style in
                    Text(style.displayName).tag(style)
                }
            }
#if os(macOS)
            .pickerStyle(.menu)
#endif
            fontControls(titleLabel: "Fuente cuenta regresiva", includeSubtitle: false)
        }
    }

    @ViewBuilder
    private func fontControls(titleLabel: String, includeSubtitle: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tipografía")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BroadcastTheme.subtleText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Picker(titleLabel, selection: $configuration.titleFont) {
                ForEach(BroadcastFontPreset.allCases, id: \.self) { font in
                    Text(font.displayName).tag(font)
                }
            }
#if os(macOS)
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
#endif
            Stepper(
                "Tamaño: \(Int(configuration.titleFontSize)) pt",
                value: $configuration.titleFontSize,
                in: 12...120
            )
            if includeSubtitle {
                Picker("Fuente subtítulo", selection: $configuration.subtitleFont) {
                    ForEach(BroadcastFontPreset.allCases, id: \.self) { font in
                        Text(font.displayName).tag(font)
                    }
                }
#if os(macOS)
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
#endif
                Stepper(
                    "Tamaño subtítulo: \(Int(configuration.subtitleFontSize)) pt",
                    value: $configuration.subtitleFontSize,
                    in: 10...48
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private func colorWellRow(_ title: String, optionalHex: Binding<String?>, fallback: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
            Spacer()
            BroadcastHexColorWell(optionalHex: optionalHex, supportsOpacity: true, fallback: fallback)
        }
    }

    private func gradientColorRow(_ title: String, hex: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.caption)
            Spacer()
            BroadcastHexColorWell(hex: hex, supportsOpacity: false)
        }
    }

    private var useTickerGradientBinding: Binding<Bool> {
        Binding(
            get: { configuration.resolvedUseTickerGradient },
            set: { configuration.useTickerGradient = $0 }
        )
    }

    private var useLowerThirdGradientBinding: Binding<Bool> {
        Binding(
            get: { configuration.resolvedUseLowerThirdGradient },
            set: { configuration.useLowerThirdGradient = $0 }
        )
    }

    private var tickerGradientStartBinding: Binding<String> {
        Binding(
            get: { configuration.tickerGradient.startColorHex },
            set: { configuration.tickerGradient.startColorHex = $0 }
        )
    }

    private var tickerGradientEndBinding: Binding<String> {
        Binding(
            get: { configuration.tickerGradient.endColorHex },
            set: { configuration.tickerGradient.endColorHex = $0 }
        )
    }

    private var lowerThirdGradientStartBinding: Binding<String> {
        Binding(
            get: { lowerThirdGradientBinding.wrappedValue.startColorHex },
            set: { lowerThirdGradientBinding.wrappedValue.startColorHex = $0 }
        )
    }

    private var lowerThirdGradientEndBinding: Binding<String> {
        Binding(
            get: { lowerThirdGradientBinding.wrappedValue.endColorHex },
            set: { lowerThirdGradientBinding.wrappedValue.endColorHex = $0 }
        )
    }

    private var lowerThirdGradientBinding: Binding<BroadcastGradientStyle> {
        Binding(
            get: {
                configuration.lowerThirdGradient
                    ?? configuration.resolvedLowerThirdGradient(fallbackAccent: configuration.accentColorHex)
            },
            set: { configuration.lowerThirdGradient = $0 }
        )
    }
}

public struct BroadcastWidgetTemplatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (BroadcastWidgetTemplate) -> Void

    public init(onSelect: @escaping (BroadcastWidgetTemplate) -> Void) {
        self.onSelect = onSelect
    }

    public var body: some View {
        NavigationStack {
            List(BroadcastWidgetTemplate.mentoTemplates, id: \.self) { template in
                Button {
                    onSelect(template)
                    dismiss()
                } label: {
                    Label(template.title, systemImage: template.systemImage)
                }
            }
            .navigationTitle("Nuevo widget Mento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 360, minHeight: 320)
#endif
    }
}
