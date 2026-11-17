import Foundation

public protocol BroadcastPlaylistRepositoryProtocol: Sendable {
    func loadAll() throws -> [BroadcastPlaylist]
    func save(_ playlist: BroadcastPlaylist) throws
    func delete(_ playlist: BroadcastPlaylist) throws
}

public final class BroadcastPlaylistRepository: BroadcastPlaylistRepositoryProtocol, @unchecked Sendable {
    private let fileManager: FileManager
    private let playlistsURL: URL

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directory = documents.appendingPathComponent("BroadcastPlaylists", isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        self.playlistsURL = directory.appendingPathComponent("playlists.json")
    }

    public func loadAll() throws -> [BroadcastPlaylist] {
        guard fileManager.fileExists(atPath: playlistsURL.path) else {
            return []
        }

        let data = try Data(contentsOf: playlistsURL)
        let playlists = try JSONDecoder().decode([BroadcastPlaylist].self, from: data)
        return playlists.sorted { $0.updatedAt > $1.updatedAt }
    }

    public func save(_ playlist: BroadcastPlaylist) throws {
        var playlists = (try? loadAll()) ?? []

        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            playlists[index] = playlist
        } else {
            playlists.insert(playlist, at: 0)
        }

        let data = try JSONEncoder().encode(playlists)
        try data.write(to: playlistsURL, options: .atomic)
    }

    public func delete(_ playlist: BroadcastPlaylist) throws {
        var playlists = try loadAll()
        playlists.removeAll { $0.id == playlist.id }
        let data = try JSONEncoder().encode(playlists)
        try data.write(to: playlistsURL, options: .atomic)
    }
}
