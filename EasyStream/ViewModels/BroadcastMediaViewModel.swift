import Foundation
import Observation
import UniformTypeIdentifiers
import EasyStreamCore
import EasyStreamUIComponents
#if os(iOS)
import UIKit
#endif

struct ProgramWidgetLayer: Identifiable, Equatable {
    let id: UUID
    let resource: BroadcastResource
    let configuration: BroadcastWidgetConfiguration
    let logoURL: URL?
    let isLive: Bool
    let isEditing: Bool
}

@MainActor
@Observable
final class BroadcastMediaViewModel {
    var imageResources: [BroadcastResource] = []
    var videoResources: [BroadcastResource] = []
    var widgetResources: [BroadcastResource] = []

    var selectedLibraryKind: BroadcastResourceKind = .image
    var librarySearchText = "" {
        didSet { invalidateFilteredResourcesCache() }
    }

    var liveWidgetIDs: Set<UUID> = []
    private var tickerExitIDs: Set<UUID> = []
    var liveFullScreenGraphicID: UUID?
    var previewFullScreenGraphicID: UUID?

    var isWidgetTemplatePickerPresented = false
    var isWidgetStudioOpen = false
    var editingWidgetResource: BroadcastResource?
    var draftWidgetConfiguration = BroadcastWidgetConfiguration()
    var draftWidgetDisplayName = ""
    var draftWidgetID = UUID()
    var isWidgetPlacementEditing = false
    /// Studio canvas plays the logo motion. Positioning turns it off so dragging stays steady.
    var isWidgetMotionPreview = true
    /// Changing this restarts the studio preview from the beginning.
    var widgetMotionEpoch = Date()

    var isPhotoPickerPresented = false
    var isWidgetLogoImporterPresented = false
    var isWidgetLogoPhotoPickerPresented = false
    var pendingImportKind: BroadcastResourceKind = .image

    var lastError: String?

    private let resourceRepository = BroadcastResourceRepository()
    private var widgetConfigurationCache: [UUID: BroadcastWidgetConfiguration] = [:]
    private var filteredResourcesCache: [BroadcastResourceKind: [BroadcastResource]] = [:]

    var isEditingExistingWidget: Bool { editingWidgetResource != nil }

    init() {
        BroadcastProgramPlatePlayer.shared.onFailure = { message in
            Task { @MainActor in
                DirectorWorkspaceSession.shared.mediaViewModel?.lastError = message
            }
        }
    }

    var allResources: [BroadcastResource] {
        imageResources + videoResources + widgetResources
    }

    var liveWidgets: [BroadcastResource] {
        widgetResources
            .filter { liveWidgetIDs.contains($0.id) }
            .sorted { $0.listLabel.localizedCaseInsensitiveCompare($1.listLabel) == .orderedAscending }
    }

    var programWidgetLayers: [ProgramWidgetLayer] {
        liveAirWidgetLayers + previewOverlayWidgetLayers
    }

    /// Committed configuration for widgets that are live on air (loaded from disk).
    var liveAirWidgetLayers: [ProgramWidgetLayer] {
        committedLiveAirWidgetLayers
    }

    /// Snapshot source for the frozen air bus — always reads persisted configuration, never draft edits.
    var committedLiveAirWidgetLayers: [ProgramWidgetLayer] {
        liveWidgets.map { resource in
            let configuration = loadedConfiguration(for: resource) ?? BroadcastWidgetConfiguration()
            return ProgramWidgetLayer(
                id: resource.id,
                resource: resource,
                configuration: configuration,
                logoURL: logoURL(for: resource, configuration: configuration),
                isLive: true,
                isEditing: false
            )
        }
    }

    /// Draft/preview widgets shown only in the director — never on external output or RTMP.
    var previewOverlayWidgetLayers: [ProgramWidgetLayer] {
        guard isWidgetStudioOpen else { return [] }

        if let editing = editingWidgetResource {
            return [
                ProgramWidgetLayer(
                    id: editing.id,
                    resource: editing,
                    configuration: draftWidgetConfiguration,
                    logoURL: logoURL(for: editing, configuration: draftWidgetConfiguration),
                    isLive: liveWidgetIDs.contains(editing.id),
                    isEditing: true
                )
            ]
        }

        if let draft = draftWidgetResource {
            return [
                ProgramWidgetLayer(
                    id: draft.id,
                    resource: draft,
                    configuration: draftWidgetConfiguration,
                    logoURL: nil,
                    isLive: false,
                    isEditing: true
                )
            ]
        }

        return []
    }

    var airFullScreenGraphicResource: BroadcastResource? {
        guard let id = liveFullScreenGraphicID else { return nil }
        return allResources.first { $0.id == id }
    }

    var previewFullScreenGraphicResource: BroadcastResource? {
        guard let id = previewFullScreenGraphicID else { return nil }
        return allResources.first { $0.id == id }
    }

    /// Live widgets for the director monitor — hides the item being edited so preview can replace it.
    var directorLiveAirWidgetLayers: [ProgramWidgetLayer] {
        guard isWidgetStudioOpen,
              let editing = editingWidgetResource,
              liveWidgetIDs.contains(editing.id) else {
            return liveAirWidgetLayers
        }
        return liveAirWidgetLayers.filter { $0.id != editing.id }
    }

    func refreshLiveAirBus() {
        LiveProgramAirStore.shared.refresh(from: self)
        syncLyrioraProgramCover()
    }

    /// Full-screen Lyriora replaces the program picture. Taking it off the air brings the selected signal back.
    private func syncLyrioraProgramCover() {
        if lyrioraFullScreenIsLive {
            DirectorWorkspaceSession.shared.sessionViewModel?.coverProgramWithLyrioraFullScreen()
        } else {
            DirectorWorkspaceSession.shared.sessionViewModel?.restoreProgramAfterLyrioraFullScreen()
        }
    }

    private var lyrioraFullScreenIsLive: Bool {
        liveWidgetIDs.contains { id in
            guard let resource = widgetResources.first(where: { $0.id == id }),
                  let configuration = loadedConfiguration(for: resource) else { return false }
            return configuration.resolvedTemplate == .lyriora
                && configuration.resolvedLyrioraMode == .fullScreen
        }
    }

    var fullScreenGraphicResource: BroadcastResource? {
        let id = liveFullScreenGraphicID ?? previewFullScreenGraphicID
        guard let id else { return nil }
        return allResources.first { $0.id == id }
    }

    private var draftWidgetResource: BroadcastResource? {
        guard isWidgetStudioOpen, editingWidgetResource == nil else { return nil }
        return BroadcastResource(
            id: draftWidgetID,
            kind: .widget,
            fileName: "draft.widget.json",
            displayName: draftWidgetDisplayName
        )
    }

    func reload() {
        do {
            imageResources = try resourceRepository.loadAll(kind: .image)
            videoResources = try resourceRepository.loadAll(kind: .video)
            widgetResources = try resourceRepository.loadAll(kind: .widget)
            rebuildWidgetConfigurationCache()
            invalidateFilteredResourcesCache()
            preloadImageThumbnails()
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Warms image and video thumbnails off the main thread so the library tabs open without hitching live cameras.
    func preloadImageThumbnails() {
        let images = imageResources.map { fileURL(for: $0) }
        let videos = videoResources.map { fileURL(for: $0) }
        guard !images.isEmpty || !videos.isEmpty else { return }
        Task(priority: .utility) {
            for url in images {
                _ = await BroadcastMediaThumbnailLoader.loadThumbnail(from: url)
            }
            for url in videos {
                _ = await BroadcastMediaThumbnailLoader.loadVideoThumbnail(from: url)
            }
        }
    }

    private func rebuildWidgetConfigurationCache() {
        widgetConfigurationCache.removeAll(keepingCapacity: true)
        for resource in widgetResources {
            if let config = try? resourceRepository.widgetConfiguration(for: resource) {
                widgetConfigurationCache[resource.id] = config
            }
        }
    }

    private func cacheWidgetConfiguration(_ configuration: BroadcastWidgetConfiguration, for id: UUID) {
        widgetConfigurationCache[id] = configuration
    }

    func resources(for kind: BroadcastResourceKind) -> [BroadcastResource] {
        switch kind {
        case .image: imageResources
        case .video: videoResources
        case .widget: widgetResources
        }
    }

    private func invalidateFilteredResourcesCache() {
        filteredResourcesCache.removeAll(keepingCapacity: true)
    }

    func filteredResources(for kind: BroadcastResourceKind) -> [BroadcastResource] {
        if let cached = filteredResourcesCache[kind] {
            return cached
        }

        let filtered = resources(for: kind).filter { resource in
            BroadcastMediaSearch.matches(librarySearchText, in: resource.listLabel)
        }
        filteredResourcesCache[kind] = filtered
        return filtered
    }

    func fileURL(for resource: BroadcastResource) -> URL {
        resourceRepository.fileURL(for: resource)
    }

    func loadedConfiguration(for resource: BroadcastResource) -> BroadcastWidgetConfiguration? {
        widgetConfigurationCache[resource.id]
    }

    func widgetConfiguration(for resource: BroadcastResource) -> BroadcastWidgetConfiguration? {
        if isWidgetStudioOpen,
           editingWidgetResource?.id == resource.id || resource.fileName == "draft.widget.json" {
            return draftWidgetConfiguration
        }
        return loadedConfiguration(for: resource)
    }

    func logoURL(for resource: BroadcastResource) -> URL? {
        logoURL(for: resource, configuration: widgetConfiguration(for: resource))
    }

    private func logoURL(for resource: BroadcastResource, configuration: BroadcastWidgetConfiguration?) -> URL? {
        guard let fileName = configuration?.logoFileName else { return nil }
        if resource.fileName == "draft.widget.json", let editing = editingWidgetResource {
            return resourceRepository.widgetLogoURL(for: editing, fileName: fileName)
        }
        return resourceRepository.widgetLogoURL(for: resource, fileName: fileName)
    }

    func beginImport(kind: BroadcastResourceKind) {
        pendingImportKind = kind
#if os(macOS)
        BroadcastMacFilePicker.pickFile(allowedTypes: allowedImportTypes(for: kind)) { [weak self] url in
            Task { @MainActor in
                guard let self, let url else { return }
                self.importFile(from: url, kind: kind)
            }
        }
#else
        isPhotoPickerPresented = true
#endif
    }

    func requestWidgetLogoImport() {
#if os(macOS)
        BroadcastMacFilePicker.pickFile(allowedTypes: [.png]) { [weak self] url in
            Task { @MainActor in
                guard let self, let url else { return }
                self.importWidgetLogo(from: url)
            }
        }
#else
        DirectorModalPresentation.afterYield { [self] in
            isWidgetLogoImporterPresented = true
        }
#endif
    }

    func requestWidgetLogoImportFromPhotoLibrary() {
#if os(iOS)
        DirectorModalPresentation.afterYield { [self] in
            isWidgetLogoPhotoPickerPresented = true
        }
#else
        requestWidgetLogoImport()
#endif
    }

    func importWidgetLogoData(_ data: Data) {
        do {
            try applyLogoData(normalizedLogoPNGData(from: data) ?? data)
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func allowedImportTypes(for kind: BroadcastResourceKind) -> [UTType] {
        switch kind {
        case .image: [.image, .jpeg, .png, .heic]
        case .video: [.movie, .mpeg4Movie, .quickTimeMovie]
        case .widget: [.json]
        }
    }

    func importData(_ data: Data, kind: BroadcastResourceKind, preferredExtension: String, displayName: String? = nil) {
        do {
            _ = try resourceRepository.importData(data, kind: kind, preferredExtension: preferredExtension, displayName: displayName)
            reload()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func importFile(from url: URL, kind: BroadcastResourceKind) {
        do {
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            _ = try resourceRepository.importFile(from: url, kind: kind, displayName: nil)
            reload()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func importWidgetLogo(from url: URL) {
        do {
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            let data = try Data(contentsOf: url)
            try applyLogoData(normalizedLogoPNGData(from: data) ?? data)
        } catch {
            lastError = error.localizedDescription
        }
    }

#if os(iOS)
    private func normalizedLogoPNGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return image.pngData()
    }
#else
    private func normalizedLogoPNGData(from data: Data) -> Data? {
        nil
    }
#endif

    private func applyLogoData(_ data: Data) throws {
        if editingWidgetResource == nil {
            saveDraftWidget()
        }
        guard let resource = editingWidgetResource else { return }
        let fileName = try resourceRepository.saveWidgetLogo(data, for: resource)
        draftWidgetConfiguration.logoFileName = fileName
        try resourceRepository.updateWidgetConfiguration(draftWidgetConfiguration, for: resource)
        reload()
        editingWidgetResource = widgetResources.first { $0.id == resource.id }
    }

    func openNewWidgetStudio(template: BroadcastWidgetTemplate) {
        WidgetStudioWindowToken.prepare()
        draftWidgetID = UUID()
        draftWidgetConfiguration = BroadcastWidgetConfiguration(template: template)
        draftWidgetConfiguration.applyTemplateDefaults()
        draftWidgetDisplayName = template.title
        editingWidgetResource = nil
        isWidgetStudioOpen = true
        isWidgetPlacementEditing = false
        isWidgetMotionPreview = true
        widgetMotionEpoch = Date()
    }

    func openWidgetStudio(for resource: BroadcastResource) {
        guard resource.kind == .widget else { return }
        WidgetStudioWindowToken.prepare()
        editingWidgetResource = resource
        draftWidgetConfiguration = loadedConfiguration(for: resource) ?? BroadcastWidgetConfiguration()
        draftWidgetDisplayName = resource.listLabel
        isWidgetStudioOpen = true
        isWidgetPlacementEditing = false
        isWidgetMotionPreview = true
        widgetMotionEpoch = Date()
    }

    func closeWidgetStudio() {
        WidgetStudioWindowToken.invalidate()
        isWidgetStudioOpen = false
        isWidgetPlacementEditing = false
        isWidgetMotionPreview = false
        editingWidgetResource = nil
    }

    func toggleWidgetPlacementEditing() {
        isWidgetPlacementEditing.toggle()
    }

    func enterWidgetPlayPreview() {
        isWidgetPlacementEditing = false
        isWidgetMotionPreview = true
        widgetMotionEpoch = Date()
    }

    func enterWidgetLayoutEditing() {
        isWidgetPlacementEditing = true
        isWidgetMotionPreview = false
    }

    @discardableResult
    func saveDraftWidget() -> Bool {
        do {
            syncTickerFields()

            if var resource = editingWidgetResource {
                try resourceRepository.updateWidgetConfiguration(draftWidgetConfiguration, for: resource)
                cacheWidgetConfiguration(draftWidgetConfiguration, for: resource.id)
                if !draftWidgetDisplayName.isEmpty {
                    resource = try resourceRepository.updateDisplayName(for: resource, to: draftWidgetDisplayName)
                }
            } else {
                let created = try resourceRepository.createWidget(
                    draftWidgetConfiguration,
                    displayName: draftWidgetDisplayName.isEmpty ? nil : draftWidgetDisplayName
                )
                cacheWidgetConfiguration(draftWidgetConfiguration, for: created.id)
                editingWidgetResource = created
            }
            reload()
            if let saved = editingWidgetResource {
                editingWidgetResource = widgetResources.first { $0.id == saved.id }
            }
            return true
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    /// Pushes the saved widget configuration to the live air bus (external output / committed graphics).
    func applyDraftToLiveAir() {
        saveDraftWidget()
        guard let resource = editingWidgetResource, liveWidgetIDs.contains(resource.id) else { return }
        refreshLiveAirBus()
    }

    func takeDraftWidgetLive() {
        saveDraftWidget()
        guard let resource = editingWidgetResource else { return }
        liveWidgetIDs.insert(resource.id)
        isWidgetPlacementEditing = false
        refreshLiveAirBus()
    }

    func takeWidgetLive(_ resource: BroadcastResource) {
        guard resource.kind == .widget else {
            takeFullScreenLive(resource)
            return
        }
        tickerExitIDs.remove(resource.id)
        liveWidgetIDs.insert(resource.id)
        refreshLiveAirBus()
    }

    func takeFullScreenLive(_ resource: BroadcastResource) {
        guard resource.kind == .image || resource.kind == .video else { return }
        previewFullScreenGraphicID = nil
        liveFullScreenGraphicID = resource.id
        refreshLiveAirBus()
        DirectorWorkspaceSession.shared.sessionViewModel?.yieldProgramPictureToMedia()
    }

    /// A camera take owns the program picture again.
    func releaseProgramMediaForCameraTake() {
        let droppingLyriora = liveWidgetIDs.filter { id in
            guard let resource = widgetResources.first(where: { $0.id == id }),
                  let configuration = loadedConfiguration(for: resource) else { return false }
            return configuration.resolvedTemplate == .lyriora
                && configuration.resolvedLyrioraMode == .fullScreen
        }
        let hadMedia = liveFullScreenGraphicID != nil || previewFullScreenGraphicID != nil
        guard hadMedia || !droppingLyriora.isEmpty else { return }
        liveFullScreenGraphicID = nil
        previewFullScreenGraphicID = nil
        liveWidgetIDs.subtract(droppingLyriora)
        refreshLiveAirBus()
    }

    func removeWidgetFromLive(_ id: UUID, closeStudioIfEditing: Bool = true) {
        if tickerExitIDs.contains(id) {
            tickerExitIDs.remove(id)
        } else if tickerCanExit(id), BroadcastMetalSpriteBus.shared.beginExit(sourceID: id) {
            tickerExitIDs.insert(id)
            let closeStudio = closeStudioIfEditing
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(500))
                guard tickerExitIDs.contains(id) else { return }
                removeWidgetFromLive(id, closeStudioIfEditing: closeStudio)
            }
            return
        }
        liveWidgetIDs.remove(id)
        if closeStudioIfEditing, editingWidgetResource?.id == id {
            closeWidgetStudio()
        }
        refreshLiveAirBus()
    }

    private func tickerCanExit(_ id: UUID) -> Bool {
        guard liveWidgetIDs.contains(id),
              let resource = widgetResources.first(where: { $0.id == id }),
              let configuration = loadedConfiguration(for: resource) else { return false }
        let template = configuration.resolvedTemplate
        return template == .ticker || template == .textBanner
    }

    func removeFullScreenFromLive() {
        liveFullScreenGraphicID = nil
        previewFullScreenGraphicID = nil
        refreshLiveAirBus()
    }

    func renameResource(_ resource: BroadcastResource, to name: String) {
        do {
            let updated = try resourceRepository.updateDisplayName(for: resource, to: name)
            replaceResource(updated)
        } catch {
            lastError = error.localizedDescription
        }
    }

    func deleteResource(_ resource: BroadcastResource) {
        do {
            let wasLive = liveWidgetIDs.contains(resource.id) || liveFullScreenGraphicID == resource.id
            tickerExitIDs.remove(resource.id)
            try resourceRepository.delete(resource)
            liveWidgetIDs.remove(resource.id)
            if liveFullScreenGraphicID == resource.id {
                liveFullScreenGraphicID = nil
            }
            if editingWidgetResource?.id == resource.id {
                closeWidgetStudio()
            }
            reload()
            if wasLive {
                refreshLiveAirBus()
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    func selectResource(_ resource: BroadcastResource) {
        if resource.kind == .widget {
            openWidgetStudio(for: resource)
        } else {
            previewFullScreenGraphicID = resource.id
        }
    }

    func takeResourceToProgram(_ resource: BroadcastResource) {
        if resource.kind == .widget {
            takeWidgetLive(resource)
        } else {
            takeFullScreenLive(resource)
        }
    }

    func clearAllGraphicsFromProgram() {
        liveWidgetIDs.removeAll()
        liveFullScreenGraphicID = nil
        previewFullScreenGraphicID = nil
        closeWidgetStudio()
        refreshLiveAirBus()
    }

    private func syncTickerFields() {
        if !draftWidgetConfiguration.tickerText.isEmpty {
            draftWidgetConfiguration.tickerTexts = [draftWidgetConfiguration.tickerText]
        }
    }

    private func replaceResource(_ resource: BroadcastResource) {
        switch resource.kind {
        case .image:
            if let index = imageResources.firstIndex(where: { $0.id == resource.id }) {
                imageResources[index] = resource
            }
        case .video:
            if let index = videoResources.firstIndex(where: { $0.id == resource.id }) {
                videoResources[index] = resource
            }
        case .widget:
            if let index = widgetResources.firstIndex(where: { $0.id == resource.id }) {
                widgetResources[index] = resource
            }
        }
    }
}

#if os(macOS)
enum BroadcastMacFilePicker {
    /// Non-blocking sheet — `runModal()` froze PROG Metal and auxiliary window scrolling.
    static func pickFile(allowedTypes: [UTType], onPick: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = allowedTypes
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.title = "Importar archivo"
        panel.prompt = "Importar"
        panel.begin { response in
            Task { @MainActor in
                onPick(response == .OK ? panel.url : nil)
            }
        }
    }
}
import AppKit
#endif
