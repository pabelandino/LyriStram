import Foundation
import EasyStreamCore

public actor FacebookGraphClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetchUserProfile(accessToken: String) async throws -> FacebookUserProfile {
        let url = graphURL(
            path: "me",
            query: [URLQueryItem(name: "fields", value: "id,name")]
        )
        let request = authorizedGET(url: url, accessToken: accessToken)
        return try await decode(FacebookUserProfile.self, from: request)
    }

    public func fetchManagedPages(userAccessToken: String) async throws -> [FacebookPage] {
        struct Response: Decodable {
            let data: [FacebookPage]
        }

        let url = graphURL(
            path: "me/accounts",
            query: [URLQueryItem(name: "fields", value: "id,name,access_token")]
        )
        let request = authorizedGET(url: url, accessToken: userAccessToken)
        let response: Response = try await decode(Response.self, from: request)
        return response.data
    }

    public func createLiveVideo(
        pageID: String,
        pageAccessToken: String,
        title: String
    ) async throws -> FacebookLiveVideo {
        let url = graphURL(
            path: "\(pageID)/live_videos",
            query: [
                URLQueryItem(name: "title", value: title),
                URLQueryItem(name: "status", value: "LIVE_NOW"),
            ]
        )
        var request = authorizedGET(url: url, accessToken: pageAccessToken)
        request.httpMethod = "POST"
        return try await decode(FacebookLiveVideo.self, from: request)
    }

    public func endLiveVideo(liveVideoID: String, accessToken: String) async throws {
        let url = graphURL(
            path: liveVideoID,
            query: [URLQueryItem(name: "end_live_video", value: "true")]
        )
        var request = authorizedGET(url: url, accessToken: accessToken)
        request.httpMethod = "POST"
        _ = try await perform(request)
    }

    private func graphURL(path: String, query: [URLQueryItem]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "graph.facebook.com"
        components.path = "/\(FacebookConfiguration.graphAPIVersion)/\(path)"
        components.queryItems = query
        return components.url!
    }

    private func authorizedGET(url: URL, accessToken: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func decode<T: Decodable>(_ type: T.Type, from request: URLRequest) async throws -> T {
        let data = try await perform(request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw FacebookGraphError.invalidResponse
        }

        if !(200...299).contains(http.statusCode) {
            if let apiError = try? JSONDecoder().decode(GraphAPIErrorResponse.self, from: data) {
                throw FacebookGraphError.apiError(apiError.error.message)
            }
            let body = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw FacebookGraphError.apiError(body)
        }

        return data
    }
}

private struct GraphAPIErrorResponse: Decodable {
    struct GraphError: Decodable {
        let message: String
    }

    let error: GraphError
}
