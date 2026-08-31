import Foundation

public struct StreamDestination: Codable, Sendable, Equatable {
    public var serverURL: String
    public var streamName: String

    public init(serverURL: String = "", streamName: String = "easystream") {
        self.serverURL = serverURL
        self.streamName = streamName
    }

    public var isConfigured: Bool {
        !serverURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !streamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

public struct ParsedStreamDestination: Sendable, Equatable {
    public let host: String
    public let port: UInt16
    public let useTLS: Bool
    public let appName: String
    public let streamName: String
}

public enum StreamDestinationError: Error, Sendable, LocalizedError {
    case invalidURL
    case missingHost
    case missingApp
    case missingStreamName

    public var errorDescription: String? {
        switch self {
        case .invalidURL: "URL de destino inválida"
        case .missingHost: "Falta el host del servidor"
        case .missingApp: "Falta el nombre de la aplicación RTMP"
        case .missingStreamName: "Falta el nombre del stream"
        }
    }
}

public extension StreamDestination {
    func parsed() throws -> ParsedStreamDestination {
        let trimmedURL = serverURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = streamName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { throw StreamDestinationError.missingStreamName }

        guard var components = URLComponents(string: trimmedURL),
              let host = components.host, !host.isEmpty else {
            throw StreamDestinationError.invalidURL
        }

        let scheme = (components.scheme ?? "rtmp").lowercased()
        let useTLS = scheme == "rtmps"
        guard scheme == "rtmp" || scheme == "rtmps" else {
            throw StreamDestinationError.invalidURL
        }

        let port = UInt16(components.port ?? (useTLS ? 443 : 1935))
        let pathParts = components.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }
        guard let appName = pathParts.first else {
            throw StreamDestinationError.missingApp
        }

        let pathStreamName = pathParts.count > 1 ? pathParts.dropFirst().joined(separator: "/") : nil
        let resolvedStreamName = pathStreamName ?? trimmedName

        return ParsedStreamDestination(
            host: host,
            port: port,
            useTLS: useTLS,
            appName: appName,
            streamName: resolvedStreamName
        )
    }
}

public enum StreamDestinationStore {
    private static let key = "com.easystream.streamDestination"

    public static func load() -> StreamDestination {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let destination = try? JSONDecoder().decode(StreamDestination.self, from: data)
        else {
            return StreamDestination()
        }
        return destination
    }

    public static func save(_ destination: StreamDestination) {
        guard let data = try? JSONEncoder().encode(destination) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

public enum StreamPublisherState: String, Sendable, Equatable {
    case idle
    case connecting
    case publishing
    case stopped
    case failed
}

public struct StreamPublisherStats: Sendable, Equatable {
    public var state: StreamPublisherState
    public var videoFramesSent: Int
    public var audioPacketsSent: Int
    public var bytesSent: Int

    public init(
        state: StreamPublisherState = .idle,
        videoFramesSent: Int = 0,
        audioPacketsSent: Int = 0,
        bytesSent: Int = 0
    ) {
        self.state = state
        self.videoFramesSent = videoFramesSent
        self.audioPacketsSent = audioPacketsSent
        self.bytesSent = bytesSent
    }
}
