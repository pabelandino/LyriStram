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
    var playlists: [BroadcastPlaylist] = []

    var selectedLibraryKind: BroadcastResourceKind = .image
    var librarySearchText = "" {
        didSet { invalidateFilteredResourcesCache() }
    }
    var selectedImagePlaylistID: UUID?
    var selectedVideoPlaylistID: UUID?
    var selectedWidgetPlaylistID: UUID?

    var liveWidgetIDs: Set<UUID> = []
    var liveFullScreenGraphicID: UUID?
    var previewFullScreenGraphicID: UUID?

    var activePlaylistID: UUID?
    var playlistQueue: [BroadcastResource] = []
    var playlistQueueIndex = 0
    var isPlaylistPlaying = false

    var isPlaylistEditorPresented = false
    var editingPlaylist: BroadcastPlaylist?

    var isWidgetTemplatePickerPresented = false
    var isWidgetStudioOpen = false
    var editingWidgetResource: BroadcastResource?
    var draftWidgetConfiguration = BroadcastWidgetConfiguration()
    var draftWidgetDisplayName = ""
    var draftWidgetID = UUID()
    var isWidgetPlacementEditing = false

    var isPhotoPickerPresented = false
    var isWidgetLogoImporterPresented = false
    var isWidgetLogoPhotoPickerPresented = false
    var pendingImportKind: BroadcastResourceKind = .image

    var lastError: String?

    private let resourceRepository = BroadcastResourceRepository()
    private let playlistRepository = BroadcastPlaylistRepository()
    private var widgetConfigurationCache: [UUID: BroadcastWidgetConfiguration] = [:]
    private var filteredResourcesCache: [BroadcastResourceKind: [BroadcastResource]] = [:]

    var isEditingExistingWidget: Bool { editingWidgetResource != nil }

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

    var playlistQueueLabel: String? {
        guard isPlaylistPlaying, playlistQueue.indices.contains(playlistQueueIndex) else { return nil }
        return playlistQueue[playlistQueueIndex].listLabel
    }

    func reload() {
        do {
            imageResources = try resourceRepository.loadAll(kind: .image)
            videoResources = try resourceRepository.loadAll(kind: .video)
            widgetResources = try resourceRepository.loadAll(kind: .widget)
            playlists = try playlistRepository.loadAll()
            rebuildWidgetConfigurationCache()
            invalidateFilteredResourcesCache()
            preloadImageThumbnails()
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Warms thumbnail cache off the main thread so opening Imágenes feels instant.
    func preloadImageThumbnails(limit: Int = 20) {
        let urls = imageResources.prefix(limit).map { fileURL(for: $0) }
        guard !urls.isEmpty else { return }
        Task(priority: .utility) {
            for url in urls {
                _ = await BroadcastMediaThumbnailLoader.loadThumbnail(from: url)
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

        let playlistID = selectedPlaylistID(for: kind)
        let filtered = resources(for: kind).filter { resource in
            let matchesSearch = BroadcastMediaSearch.matches(librarySearchText, in: resource.listLabel)
            guard matchesSearch else { return false }
            guard let playlistID,
                  let playlist = playlists.first(where: { $0.id == playlistID }) else {
                return true
            }
            return playlist.itemIDs.contains(resource.id)
        }
        filteredResourcesCache[kind] = filtered
        return filtered
    }

    func selectedPlaylistID(for kind: BroadcastResourceKind) -> UUID? {
        switch kind {
        case .image: selectedImagePlaylistID
        case .video: selectedVideoPlaylistID
        case .widget: selectedWidgetPlaylistID
        }
    }

    func setSelectedPlaylistID(_ id: UUID?, for kind: BroadcastResourceKind) {
        switch kind {
        case .image: selectedImagePlaylistID = id
        case .video: selectedVideoPlaylistID = id
        case .widget: selectedWidgetPlaylistID = id
        }
        invalidateFilteredResourcesCache()
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
        isWidgetLogoImporterPresented = true
#endif
    }

    func requestWidgetLogoImportFromPhotoLibrary() {
#if os(iOS)
        isWidgetLogoPhotoPickerPresented = true
#else
        requestWidgetLogoImport()
#endif
    }

    func importWidgetLogoData(_ data: Data) {
        do {
#if os(iOS)
            let normalized: Data
            if let image = UIImage(data: data), let png = image.pngData() {
                normalized = png
            } else {
                normalized = data
            }
            try applyLogoData(normalized)
#else
            try applyLogoData(data)
#endif
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
            try applyLogoData(data)
        } catch {
            lastError = error.localizedDescription
        }
    }

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
        draftWidgetID = UUID()
        draftWidgetConfiguration = BroadcastWidgetConfiguration(template: template)
        draftWidgetConfiguration.applyTemplateDefaults()
        draftWidgetDisplayName = template.title
        editingWidgetResource = nil
        isWidgetStudioOpen = true
        isWidgetPlacementEditing = false
        LiveProgramAirStore.shared.setDirectorEditingWidget(nil)
    }

    func openWidgetStudio(for resource: BroadcastResource) {
        guard resource.kind == .widget else { return }
        editingWidgetResource = resource
        draftWidgetConfiguration = loadedConfiguration(for: resource) ?? BroadcastWidgetConfiguration()
        draftWidgetDisplayName = resource.listLabel
        isWidgetStudioOpen = true
        isWidgetPlacementEditing = false
        if liveWidgetIDs.contains(resource.id) {
            LiveProgramAirStore.shared.setDirectorEditingWidget(resource.id)
        } else {
            LiveProgramAirStore.shared.setDirectorEditingWidget(nil)
        }
    }

    func closeWidgetStudio() {
        isWidgetStudioOpen = false
        isWidgetPlacementEditing = false
        editingWidgetResource = nil
        LiveProgramAirStore.shared.setDirectorEditingWidget(nil)
    }

    func toggleWidgetPlacementEditing() {
        isWidgetPlacementEditing.toggle()
    }

    func enterWidgetPlayPreview() {
        isWidgetPlacementEditing = false
    }

    func enterWidgetLayoutEditing() {
        isWidgetPlacementEditing = true
    }

    func saveDraftWidget() {
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
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Pushes the saved widget configuration to the live air bus (external output / committed graphics).
    func applyDraftToLiveAir() {
        saveDraftWidget()
        guard let resource = editingWidgetResource, liveWidgetIDs.contains(resource.id) else { return }
        refreshLiveAirBus()
    }

    func previewDraftWidget() {
        enterWidgetPlayPreview()
    }

    func takeDraftWidgetLive() {
        saveDraftWidget()
        guard let resource = editingWidgetResource else { return }
        liveWidgetIDs.insert(resource.id)
        isWidgetPlacementEditing = false
        if isWidgetStudioOpen {
            LiveProgramAirStore.shared.setDirectorEditingWidget(resource.id)
        }
        refreshLiveAirBus()
    }

    func takeWidgetLive(_ resource: BroadcastResource) {
        guard resource.kind == .widget else {
            takeFullScreenLive(resource)
            return
        }
        liveWidgetIDs.insert(resource.id)
        refreshLiveAirBus()
    }

    func takeFullScreenLive(_ resource: BroadcastResource) {
        previewFullScreenGraphicID = nil
        liveFullScreenGraphicID = resource.id
        refreshLiveAirBus()
    }

    func removeWidgetFromLive(_ id: UUID, closeStudioIfEditing: Bool = true) {
        liveWidgetIDs.remove(id)
        if closeStudioIfEditing, editingWidgetResource?.id == id {
            closeWidgetStudio()
        }
        refreshLiveAirBus()
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
            openWidgetStudio(for: resource)
            takeDraftWidgetLive()
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

    func createPlaylist(name: String, kind: BroadcastPlaylistKind, itemIDs: [UUID]) {
        var playlist = BroadcastPlaylist(name: name, kind: kind, itemIDs: itemIDs)
        playlist.updatedAt = .now
        savePlaylist(playlist)
    }

    func savePlaylist(_ playlist: BroadcastPlaylist) {
        do {
            var updated = playlist
            updated.updatedAt = .now
            try playlistRepository.save(updated)
            reload()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func deletePlaylist(_ playlist: BroadcastPlaylist) {
        do {
            try playlistRepository.delete(playlist)
            if activePlaylistID == playlist.id {
                stopPlaylistPlayback()
            }
            reload()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func playPlaylist(_ playlist: BroadcastPlaylist) {
        let items = playlist.itemIDs.compactMap { id in allResources.first { $0.id == id } }
        guard !items.isEmpty else {
            lastError = "La playlist está vacía"
            return
        }
        activePlaylistID = playlist.id
        playlistQueue = items
        playlistQueueIndex = 0
        isPlaylistPlaying = true
        applyPlaylistItem(items[0])
    }

    func playNextInQueue() {
        guard isPlaylistPlaying else { return }
        let nextIndex = playlistQueueIndex + 1
        guard playlistQueue.indices.contains(nextIndex) else {
            stopPlaylistPlayback()
            return
        }
        playlistQueueIndex = nextIndex
        applyPlaylistItem(playlistQueue[nextIndex])
    }

    func stopPlaylistPlayback() {
        isPlaylistPlaying = false
        activePlaylistID = nil
        playlistQueue = []
        playlistQueueIndex = 0
    }

    private func applyPlaylistItem(_ resource: BroadcastResource) {
        if resource.kind == .widget {
            liveWidgetIDs.insert(resource.id)
        } else {
            liveFullScreenGraphicID = resource.id
        }
        refreshLiveAirBus()
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
    static func pickFile(allowedTypes: [UTType], onPick: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = allowedTypes
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.title = "Importar archivo"
        panel.prompt = "Importar"
        if panel.runModal() == .OK {
            onPick(panel.url)
        } else {
            onPick(nil)
        }
    }
}
import AppKit
#endif
