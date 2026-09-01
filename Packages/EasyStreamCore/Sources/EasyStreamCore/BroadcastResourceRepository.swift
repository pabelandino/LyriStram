import Foundation

public protocol BroadcastResourceRepositoryProtocol: Sendable {
    func loadAll(kind: BroadcastResourceKind) throws -> [BroadcastResource]
    func importData(
        _ data: Data,
        kind: BroadcastResourceKind,
        preferredExtension: String,
        displayName: String?
    ) throws -> BroadcastResource
    func importFile(from sourceURL: URL, kind: BroadcastResourceKind, displayName: String?) throws -> BroadcastResource
    func createWidget(_ configuration: BroadcastWidgetConfiguration, displayName: String?) throws -> BroadcastResource
    func updateWidgetConfiguration(_ configuration: BroadcastWidgetConfiguration, for asset: BroadcastResource) throws
    func saveWidgetLogo(_ data: Data, for asset: BroadcastResource) throws -> String
    func widgetLogoURL(for asset: BroadcastResource, fileName: String) -> URL
    func widgetConfiguration(for asset: BroadcastResource) throws -> BroadcastWidgetConfiguration?
    func fileURL(for asset: BroadcastResource) -> URL
    func updateDisplayName(for asset: BroadcastResource, to displayName: String) throws -> BroadcastResource
    func delete(_ asset: BroadcastResource) throws
}

private struct BroadcastResourceIndexEntry: Codable {
    var displayName: String?
    var assetID: UUID?
}

public final class BroadcastResourceRepository: BroadcastResourceRepositoryProtocol, @unchecked Sendable {
    private let fileManager: FileManager
    private let mediaDirectory: URL
    private let indexURL: URL

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.mediaDirectory = documents.appendingPathComponent("BroadcastMedia", isDirectory: true)
        self.indexURL = mediaDirectory.appendingPathComponent("index.json")

        for kind in BroadcastResourceKind.allCases {
            let folder = mediaDirectory.appendingPathComponent(kind.rawValue, isDirectory: true)
            if !fileManager.fileExists(atPath: folder.path) {
                try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            }
        }
    }

    public func loadAll(kind: BroadcastResourceKind) throws -> [BroadcastResource] {
        let folder = mediaDirectory.appendingPathComponent(kind.rawValue, isDirectory: true)
        let urls = try fileManager.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )
        let index = loadIndex()

        let resourceURLs: [URL]
        switch kind {
        case .widget:
            resourceURLs = urls.filter { $0.lastPathComponent.hasSuffix(".widget.json") }
        default:
            resourceURLs = urls
        }

        return resourceURLs.map { url in
            let fileName = url.lastPathComponent
            let createdAt = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .now
            let entry = index[fileName]
            let assetID = entry?.assetID ?? UUID()

            if entry?.assetID == nil {
                saveIndexEntry(
                    BroadcastResourceIndexEntry(displayName: entry?.displayName, assetID: assetID),
                    for: fileName
                )
            }

            return BroadcastResource(
                id: assetID,
                kind: kind,
                fileName: fileName,
                displayName: entry?.displayName,
                createdAt: createdAt
            )
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    public func importData(
        _ data: Data,
        kind: BroadcastResourceKind,
        preferredExtension: String,
        displayName: String? = nil
    ) throws -> BroadcastResource {
        let fileName = "\(UUID().uuidString).\(preferredExtension)"
        let destination = mediaDirectory
            .appendingPathComponent(kind.rawValue, isDirectory: true)
            .appendingPathComponent(fileName)

        try data.write(to: destination, options: .atomic)

        let resolvedDisplayName = BroadcastDisplayNameSanitizer.sanitized(displayName, fallbackFileName: fileName)
        let asset = BroadcastResource(
            kind: kind,
            fileName: fileName,
            displayName: resolvedDisplayName
        )
        saveIndexEntry(
            BroadcastResourceIndexEntry(displayName: resolvedDisplayName, assetID: asset.id),
            for: fileName
        )

        return asset
    }

    public func importFile(
        from sourceURL: URL,
        kind: BroadcastResourceKind,
        displayName: String? = nil
    ) throws -> BroadcastResource {
        let preferredExtension = sourceURL.pathExtension.isEmpty
            ? defaultExtension(for: kind)
            : sourceURL.pathExtension
        let fileName = "\(UUID().uuidString).\(preferredExtension)"
        let destination = mediaDirectory
            .appendingPathComponent(kind.rawValue, isDirectory: true)
            .appendingPathComponent(fileName)

        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }

        try fileManager.copyItem(at: sourceURL, to: destination)

        let fallbackName = (sourceURL.lastPathComponent as NSString).deletingPathExtension
        let resolvedDisplayName = BroadcastDisplayNameSanitizer.sanitized(
            displayName ?? fallbackName,
            fallbackFileName: fileName
        )
        let asset = BroadcastResource(
            kind: kind,
            fileName: fileName,
            displayName: resolvedDisplayName
        )
        saveIndexEntry(
            BroadcastResourceIndexEntry(displayName: resolvedDisplayName, assetID: asset.id),
            for: fileName
        )

        return asset
    }

    public func createWidget(
        _ configuration: BroadcastWidgetConfiguration,
        displayName: String? = nil
    ) throws -> BroadcastResource {
        let fileName = "\(UUID().uuidString).widget.json"
        let destination = mediaDirectory
            .appendingPathComponent(BroadcastResourceKind.widget.rawValue, isDirectory: true)
            .appendingPathComponent(fileName)

        let data = try JSONEncoder().encode(configuration)
        try data.write(to: destination, options: .atomic)

        let resolvedDisplayName = BroadcastDisplayNameSanitizer.sanitized(
            displayName ?? configuration.title,
            fallbackFileName: fileName
        )
        let asset = BroadcastResource(
            kind: .widget,
            fileName: fileName,
            displayName: resolvedDisplayName
        )
        saveIndexEntry(
            BroadcastResourceIndexEntry(displayName: resolvedDisplayName, assetID: asset.id),
            for: fileName
        )

        return asset
    }

    public func updateWidgetConfiguration(
        _ configuration: BroadcastWidgetConfiguration,
        for asset: BroadcastResource
    ) throws {
        guard asset.kind == .widget else { return }
        let destination = fileURL(for: asset)
        let data = try JSONEncoder().encode(configuration)
        try data.write(to: destination, options: .atomic)
    }

    public func saveWidgetLogo(_ data: Data, for asset: BroadcastResource) throws -> String {
        guard asset.kind == .widget else {
            throw BroadcastResourceRepositoryError.invalidWidgetAsset
        }
        let logoFileName = asset.fileName.replacingOccurrences(of: ".widget.json", with: "_logo.png")
        let destination = fileURL(for: asset).deletingLastPathComponent().appendingPathComponent(logoFileName)
        try data.write(to: destination, options: .atomic)
        return logoFileName
    }

    public func widgetLogoURL(for asset: BroadcastResource, fileName: String) -> URL {
        fileURL(for: asset).deletingLastPathComponent().appendingPathComponent(fileName)
    }

    public func widgetConfiguration(for asset: BroadcastResource) throws -> BroadcastWidgetConfiguration? {
        guard asset.kind == .widget else { return nil }
        let data = try Data(contentsOf: fileURL(for: asset))
        var configuration = try JSONDecoder().decode(BroadcastWidgetConfiguration.self, from: data)
        if configuration.tickerText.isEmpty {
            configuration.tickerText = configuration.tickerTexts.first ?? configuration.title
        }
        return configuration
    }

    public func fileURL(for asset: BroadcastResource) -> URL {
        mediaDirectory
            .appendingPathComponent(asset.kind.rawValue, isDirectory: true)
            .appendingPathComponent(asset.fileName)
    }

    public func delete(_ asset: BroadcastResource) throws {
        let url = fileURL(for: asset)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        if asset.kind == .widget {
            let logoBase = asset.fileName.replacingOccurrences(of: ".widget.json", with: "_logo.png")
            let logoURL = url.deletingLastPathComponent().appendingPathComponent(logoBase)
            if fileManager.fileExists(atPath: logoURL.path) {
                try? fileManager.removeItem(at: logoURL)
            }
            removeIndexEntry(for: logoBase)
        }
        removeIndexEntry(for: asset.fileName)
    }

    public func updateDisplayName(for asset: BroadcastResource, to displayName: String) throws -> BroadcastResource {
        let resolvedDisplayName = BroadcastDisplayNameSanitizer.sanitized(displayName, fallbackFileName: asset.fileName)
        var entry = loadIndex()[asset.fileName] ?? BroadcastResourceIndexEntry(assetID: asset.id)
        entry.displayName = resolvedDisplayName
        entry.assetID = asset.id
        saveIndexEntry(entry, for: asset.fileName)

        var updatedAsset = asset
        updatedAsset.displayName = resolvedDisplayName
        return updatedAsset
    }

    private func defaultExtension(for kind: BroadcastResourceKind) -> String {
        switch kind {
        case .image: "jpg"
        case .video: "mp4"
        case .widget: "widget.json"
        }
    }

    private func loadIndex() -> [String: BroadcastResourceIndexEntry] {
        guard fileManager.fileExists(atPath: indexURL.path),
              let data = try? Data(contentsOf: indexURL) else {
            return [:]
        }

        if let index = try? JSONDecoder().decode([String: BroadcastResourceIndexEntry].self, from: data) {
            return index
        }

        if let legacyIndex = try? JSONDecoder().decode([String: String].self, from: data) {
            return legacyIndex.mapValues { BroadcastResourceIndexEntry(displayName: $0, assetID: nil) }
        }

        return [:]
    }

    private func saveIndexEntry(_ entry: BroadcastResourceIndexEntry, for fileName: String) {
        var index = loadIndex()
        index[fileName] = entry

        guard let data = try? JSONEncoder().encode(index) else { return }
        try? data.write(to: indexURL, options: .atomic)
    }

    private func removeIndexEntry(for fileName: String) {
        var index = loadIndex()
        index.removeValue(forKey: fileName)

        guard let data = try? JSONEncoder().encode(index) else { return }
        try? data.write(to: indexURL, options: .atomic)
    }
}

public enum BroadcastResourceRepositoryError: Error {
    case invalidWidgetAsset
}
