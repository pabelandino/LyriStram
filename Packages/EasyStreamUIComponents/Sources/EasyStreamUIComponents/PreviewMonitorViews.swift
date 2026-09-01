import SwiftUI
import EasyStreamCore
import WebRTC

public struct PreviewMonitorCamera: Identifiable, Equatable {
    public let id: CameraSourceID
    public let displayName: String
    public let track: RTCVideoTrack?
    public let isConnected: Bool
    public let isMuted: Bool
    public let sourceIndex: Int

    public init(
        id: CameraSourceID,
        displayName: String,
        track: RTCVideoTrack?,
        isConnected: Bool,
        isMuted: Bool,
        sourceIndex: Int
    ) {
        self.id = id
        self.displayName = displayName
        self.track = track
        self.isConnected = isConnected
        self.isMuted = isMuted
        self.sourceIndex = sourceIndex
    }
}

public struct PreviewMonitorMultiviewGrid: View {
    let cameras: [PreviewMonitorCamera]
    let previewSourceID: CameraSourceID?
    let programSourceID: CameraSourceID?
    let programAudioSourceID: CameraSourceID?
    let settings: PreviewMonitorSettings
    let currentPage: Int
    let onSelect: (CameraSourceID) -> Void

    public init(
        cameras: [PreviewMonitorCamera],
        previewSourceID: CameraSourceID?,
        programSourceID: CameraSourceID?,
        programAudioSourceID: CameraSourceID?,
        settings: PreviewMonitorSettings,
        currentPage: Int,
        onSelect: @escaping (CameraSourceID) -> Void
    ) {
        self.cameras = cameras
        self.previewSourceID = previewSourceID
        self.programSourceID = programSourceID
        self.programAudioSourceID = programAudioSourceID
        self.settings = settings
        self.currentPage = currentPage
        self.onSelect = onSelect
    }

    public var body: some View {
        GeometryReader { geometry in
            let spec = PreviewMultiviewLayoutEngine.gridSpec(
                for: cameras.count,
                mode: settings.layoutMode
            )
            let showHero = settings.layoutMode == .programPlusGrid && settings.overlays.showProgramInGrid
            let pageCount = PreviewMultiviewLayoutEngine.pageCount(
                cameraCount: cameras.count,
                spec: spec,
                includesProgramHero: showHero
            )
            let page = min(max(0, currentPage), max(0, pageCount - 1))
            let pageCameras = pagedCameras(page: page, spec: spec, showHero: showHero)

            VStack(spacing: settings.appearance.cellGap) {
                if showHero, let programID = programSourceID,
                   let programCamera = cameras.first(where: { $0.id == programID }) {
                    PreviewMonitorCellView(
                        camera: programCamera,
                        settings: settings,
                        isPreview: programID == previewSourceID,
                        isProgram: true,
                        isAudio: programID == programAudioSourceID,
                        onSelect: onSelect
                    )
                    .frame(height: geometry.size.height * 0.42)
                }

                gridBody(
                    cameras: pageCameras,
                    spec: spec,
                    size: geometry.size,
                    showHero: showHero,
                    pageCount: pageCount
                )

                if pageCount > 1 {
                    pageIndicator(page: page, pageCount: pageCount)
                }
            }
            .padding(settings.appearance.cellGap)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(color(from: settings.appearance.background))
        }
    }

    @ViewBuilder
    private func gridBody(
        cameras pageCameras: [PreviewMonitorCamera],
        spec: PreviewMultiviewGridSpec,
        size: CGSize,
        showHero: Bool,
        pageCount: Int
    ) -> some View {
        let gap = settings.appearance.cellGap
        let rows = settings.layoutMode == .stripHorizontal ? 1 : spec.rows
        let columns = settings.layoutMode == .stripHorizontal ? max(1, pageCameras.count) : spec.columns
        let heroHeight = showHero ? size.height * 0.42 + gap : 0
        let availableHeight = max(0, size.height - heroHeight - gap * 2 - (pageCount > 1 ? 28 : 0))
        let cellWidth = (size.width - gap * Double(columns + 1)) / Double(columns)
        let cellHeight = (availableHeight - gap * Double(rows + 1)) / Double(rows)

        if settings.layoutMode == .stripHorizontal {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: gap) {
                    ForEach(pageCameras) { camera in
                        cell(for: camera)
                            .frame(width: max(180, cellWidth), height: max(100, cellHeight))
                    }
                }
                .padding(.horizontal, gap)
            }
        } else {
            let gridItems = Array(repeating: GridItem(.fixed(max(80, cellWidth)), spacing: gap), count: columns)
            LazyVGrid(columns: gridItems, spacing: gap) {
                ForEach(pageCameras) { camera in
                    cell(for: camera)
                        .frame(width: max(80, cellWidth), height: max(60, cellHeight))
                }
            }
        }
    }

    private var pageCount: Int {
        let spec = PreviewMultiviewLayoutEngine.gridSpec(for: cameras.count, mode: settings.layoutMode)
        let showHero = settings.layoutMode == .programPlusGrid && settings.overlays.showProgramInGrid
        return PreviewMultiviewLayoutEngine.pageCount(
            cameraCount: cameras.count,
            spec: spec,
            includesProgramHero: showHero
        )
    }

    private func pagedCameras(page: Int, spec: PreviewMultiviewGridSpec, showHero: Bool) -> [PreviewMonitorCamera] {
        let reserved = showHero ? 2 : 0
        let capacity = max(1, spec.pageCapacity - reserved)
        let start = page * capacity
        guard start < cameras.count else { return [] }
        let end = min(start + capacity, cameras.count)
        return Array(cameras[start..<end])
    }

    private func cell(for camera: PreviewMonitorCamera) -> some View {
        PreviewMonitorCellView(
            camera: camera,
            settings: settings,
            isPreview: camera.id == previewSourceID,
            isProgram: camera.id == programSourceID,
            isAudio: camera.id == programAudioSourceID,
            onSelect: onSelect
        )
    }

    private func pageIndicator(page: Int, pageCount: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == page ? Color.white : Color.white.opacity(0.25))
                    .frame(width: 8, height: 8)
            }
            Text("Página \(page + 1)/\(pageCount)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

    private func color(from rgb: PreviewMonitorRGBColor) -> Color {
        Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}

public struct PreviewMonitorCellView: View {
    let camera: PreviewMonitorCamera
    let settings: PreviewMonitorSettings
    let isPreview: Bool
    let isProgram: Bool
    let isAudio: Bool
    let onSelect: (CameraSourceID) -> Void

    public var body: some View {
        Button {
            onSelect(camera.id)
        } label: {
            ZStack {
                videoLayer
                overlayLayer
                if settings.overlays.showSafeAreaGuides {
                    safeAreaGuides
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: settings.appearance.borderWidth)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var videoLayer: some View {
        if let track = camera.track {
            BoundedWebRTCVideoView(track: track)
        } else {
            ZStack {
                Color.black.opacity(0.9)
                VStack(spacing: 6) {
                    Image(systemName: camera.isConnected ? "video" : "video.slash")
                    Text(camera.isConnected ? "Conectando…" : "Sin señal")
                        .font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.55))
            }
        }
    }

    private var overlayLayer: some View {
        VStack {
            HStack(alignment: .top) {
                leadingLabels
                Spacer()
                tallyBadges
            }
            Spacer()
            bottomBar
        }
        .padding(8)
    }

    @ViewBuilder
    private var leadingLabels: some View {
        VStack(alignment: .leading, spacing: 4) {
            if settings.overlays.showSourceIndex {
                Text(String(format: "%02d", camera.sourceIndex + 1))
                    .font(.caption.weight(.heavy).monospacedDigit())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 4))
            }
            if settings.overlays.showCameraName {
                Text(camera.displayName)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 4))
            }
        }
        .foregroundStyle(.white)
    }

    @ViewBuilder
    private var tallyBadges: some View {
        if settings.overlays.showTallyBadges {
            VStack(alignment: .trailing, spacing: 4) {
                if isProgram && settings.overlays.highlightProgramSource {
                    tallyBadge(BroadcastTerminology.programShort, color: color(from: settings.appearance.programBorder))
                }
                if isPreview && settings.overlays.highlightPreviewSource {
                    tallyBadge(BroadcastTerminology.previewShort, color: color(from: settings.appearance.previewBorder))
                }
                if isAudio && settings.overlays.showAudioIndicator {
                    tallyBadge(BroadcastTerminology.audioShort, color: color(from: settings.appearance.audioAccent))
                }
            }
        }
    }

    @ViewBuilder
    private var bottomBar: some View {
        HStack {
            if settings.overlays.showConnectionStatus {
                Label(
                    camera.isConnected ? "Live" : "Offline",
                    systemImage: camera.isConnected ? "dot.radiowaves.left.and.right" : "exclamationmark.triangle"
                )
                .font(.caption2.weight(.semibold))
                .foregroundStyle(camera.isConnected ? .green : .orange)
            }
            Spacer()
            if settings.overlays.showAudioIndicator && camera.isMuted {
                Label("Mute", systemImage: "mic.slash.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 4))
        .foregroundStyle(.white)
    }

    private var safeAreaGuides: some View {
        GeometryReader { proxy in
            let insetX = proxy.size.width * 0.1
            let insetY = proxy.size.height * 0.1
            Rectangle()
                .strokeBorder(Color.yellow.opacity(0.35), lineWidth: 1)
                .padding(.horizontal, insetX)
                .padding(.vertical, insetY)
        }
        .allowsHitTesting(false)
    }

    private var borderColor: Color {
        if isProgram && settings.overlays.highlightProgramSource {
            return color(from: settings.appearance.programBorder)
        }
        if isPreview && settings.overlays.highlightPreviewSource {
            return color(from: settings.appearance.previewBorder)
        }
        return Color.white.opacity(0.15)
    }

    private func tallyBadge(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.caption2.weight(.black))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color, in: Capsule())
            .foregroundStyle(.white)
    }

    private func color(from rgb: PreviewMonitorRGBColor) -> Color {
        Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}

public struct PreviewMonitorInspectorSummary: View {
    let layoutName: String
    let onOpenMonitor: () -> Void
    let onConfigure: () -> Void

    public init(
        layoutName: String,
        onOpenMonitor: @escaping () -> Void,
        onConfigure: @escaping () -> Void
    ) {
        self.layoutName = layoutName
        self.onOpenMonitor = onOpenMonitor
        self.onConfigure = onConfigure
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Grid en segunda pantalla · \(layoutName)")
                .font(.caption)
                .foregroundStyle(BroadcastTheme.subtleText)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onOpenMonitor) {
                Label("Abrir monitor", systemImage: "display.2")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
            .controlSize(.regular)

            Button("Configurar ajustes…", action: onConfigure)
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .controlSize(.regular)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public struct PreviewMonitorSettingsSheet: View {
    @Binding var settings: PreviewMonitorSettings
    let onOpenMonitor: () -> Void
    @Environment(\.dismiss) private var dismiss

    public init(settings: Binding<PreviewMonitorSettings>, onOpenMonitor: @escaping () -> Void) {
        _settings = settings
        self.onOpenMonitor = onOpenMonitor
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                PreviewMonitorSettingsForm(settings: $settings, onOpenMonitor: onOpenMonitor)
                    .padding(20)
            }
            .navigationTitle("Monitor multiview")
#if os(macOS)
            .frame(minWidth: 480, minHeight: 560)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}

public struct PreviewMonitorSettingsForm: View {
    @Binding var settings: PreviewMonitorSettings
    let onOpenMonitor: () -> Void

    public init(settings: Binding<PreviewMonitorSettings>, onOpenMonitor: @escaping () -> Void) {
        _settings = settings
        self.onOpenMonitor = onOpenMonitor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Abre un grid profesional en otra pantalla para ver todas las cámaras.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button(action: onOpenMonitor) {
                    Label("Abrir monitor ahora", systemImage: "display.2")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BroadcastGlowButtonStyle(tint: BroadcastTheme.studioAccent, isProminent: true))
            }

            Picker("Layout", selection: $settings.layoutMode) {
                ForEach(PreviewMonitorLayoutMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .broadcastNativeSegmentedControl()

            Toggle("Abrir en segunda pantalla", isOn: $settings.openOnExternalDisplay)
                .toggleStyle(.switch)
            Toggle("Paginar automáticamente", isOn: $settings.autoPaginate)
                .toggleStyle(.switch)

            if settings.autoPaginate {
                HStack {
                    Text("Intervalo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Slider(value: $settings.pageIntervalSeconds, in: 3...15, step: 1)
                    Text("\(Int(settings.pageIntervalSeconds))s")
                        .font(.caption.monospacedDigit())
                        .frame(width: 28, alignment: .trailing)
                }
            }

            Group {
                Text("Overlays")
                    .font(.subheadline.weight(.semibold))
                overlayToggle("Nombre de cámara", keyPath: \.showCameraName)
                overlayToggle("Índice de fuente", keyPath: \.showSourceIndex)
                overlayToggle("Tally PVW/PRG/AUDIO", keyPath: \.showTallyBadges)
                overlayToggle("Resaltar preview", keyPath: \.highlightPreviewSource)
                overlayToggle("Resaltar programa", keyPath: \.highlightProgramSource)
                overlayToggle("Estado de conexión", keyPath: \.showConnectionStatus)
                overlayToggle("Indicador de audio", keyPath: \.showAudioIndicator)
                overlayToggle("Guías de safe area", keyPath: \.showSafeAreaGuides)
                overlayToggle("Programa grande en grid", keyPath: \.showProgramInGrid)
            }

            Group {
                Text("Colores tally")
                    .font(.subheadline.weight(.semibold))
                colorPresetRow("Preview", color: .previewGreen) {
                    settings.appearance.previewBorder = .previewGreen
                }
                colorPresetRow("Programa", color: .programRed) {
                    settings.appearance.programBorder = .programRed
                }
                colorPresetRow("Audio", color: .audioGold) {
                    settings.appearance.audioAccent = .audioGold
                }
            }

            HStack {
                Text("Separación")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $settings.appearance.cellGap, in: 0...12, step: 1)
                Text("\(Int(settings.appearance.cellGap))pt")
                    .font(.caption.monospacedDigit())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func overlayToggle(_ title: String, keyPath: WritableKeyPath<PreviewMonitorOverlayOptions, Bool>) -> some View {
        Toggle(title, isOn: Binding(
            get: { settings.overlays[keyPath: keyPath] },
            set: { settings.overlays[keyPath: keyPath] = $0 }
        ))
        .toggleStyle(.switch)
    }

    private func colorPresetRow(_ title: String, color: PreviewMonitorRGBColor, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(Color(red: color.red, green: color.green, blue: color.blue))
                    .frame(width: 14, height: 14)
                Text(title)
                Spacer()
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

/// Legacy alias — use `PreviewMonitorInspectorSummary` + `PreviewMonitorSettingsSheet`.
public struct PreviewMonitorSettingsPanel: View {
    @Binding var settings: PreviewMonitorSettings
    let onOpenMonitor: () -> Void

    public init(settings: Binding<PreviewMonitorSettings>, onOpenMonitor: @escaping () -> Void) {
        _settings = settings
        self.onOpenMonitor = onOpenMonitor
    }

    public var body: some View {
        PreviewMonitorSettingsForm(settings: $settings, onOpenMonitor: onOpenMonitor)
    }
}

public struct PreviewMonitorHeaderBar: View {
    let cameraCount: Int
    let previewName: String?
    let programName: String?
    let layoutName: String
    let page: Int
    let pageCount: Int

    public init(
        cameraCount: Int,
        previewName: String?,
        programName: String?,
        layoutName: String,
        page: Int,
        pageCount: Int
    ) {
        self.cameraCount = cameraCount
        self.previewName = previewName
        self.programName = programName
        self.layoutName = layoutName
        self.page = page
        self.pageCount = pageCount
    }

    public var body: some View {
        HStack(spacing: 16) {
            Label("MONITOR MULTIVIEW", systemImage: "rectangle.split.3x3")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text("\(cameraCount) cámara(s)")
                .font(.caption)

            if let previewName {
                Text("PVW: \(previewName)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }

            if let programName {
                Text("PRG: \(programName)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            }

            Spacer()

            Text(layoutName)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)

            if pageCount > 1 {
                Text("Pág. \(page + 1)/\(pageCount)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }
}
