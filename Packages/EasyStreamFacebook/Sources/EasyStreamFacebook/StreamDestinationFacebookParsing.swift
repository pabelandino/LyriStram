import Foundation
import EasyStreamCore

public enum StreamDestinationFacebookParsing {
    /// Parses a Facebook `secure_stream_url` into server URL + stream key for RTMP publishing.
    public static func destination(fromSecureStreamURL urlString: String) -> StreamDestination? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), let host = url.host else { return nil }

        let scheme = (url.scheme ?? "rtmps").lowercased()
        let port = url.port ?? 443
        let prefix = "/rtmp/"
        guard url.path.hasPrefix(prefix) else { return nil }

        let streamKeyBase = String(url.path.dropFirst(prefix.count))
        guard !streamKeyBase.isEmpty else { return nil }

        let streamName: String
        if let query = url.query, !query.isEmpty {
            streamName = "\(streamKeyBase)?\(query)"
        } else {
            streamName = streamKeyBase
        }

        let serverURL = "\(scheme)://\(host):\(port)/rtmp"
        return StreamDestination(serverURL: serverURL, streamName: streamName)
    }
}
