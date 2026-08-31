import Foundation
import EasyStreamCore

public actor FacebookLiveService {
    private let graph = FacebookGraphClient()

    public init() {}

    public func restoreSession() -> FacebookSession {
        FacebookSessionStore.load()
    }

    public func signOut() {
        FacebookSessionStore.clear()
    }

    public func signIn() async throws -> FacebookSession {
        let token = try await FacebookAuthService.shared.signIn()
        do {
            let profile = try await graph.fetchUserProfile(accessToken: token)
            var session = FacebookSession(userAccessToken: token, userProfile: profile)
            FacebookSessionStore.save(session)
            EasyStreamLog.facebook.info("Facebook signed in as \(profile.name, privacy: .public)")
            return session
        } catch let FacebookGraphError.apiError(message)
            where message.localizedCaseInsensitiveContains("cannot parse access token") {
            throw FacebookAuthError.limitedLoginRequiresTracking
        }
    }

    public func authorizePages(for session: FacebookSession) async throws -> FacebookSession {
        let token = try await FacebookAuthService.shared.authorizePages()
        var updatedSession = session
        updatedSession.userAccessToken = token
        FacebookSessionStore.save(updatedSession)
        return updatedSession
    }

    public func fetchPages(for session: FacebookSession) async throws -> [FacebookPage] {
        try await graph.fetchManagedPages(userAccessToken: session.userAccessToken)
    }

    public func prepareLiveBroadcast(
        session: FacebookSession,
        page: FacebookPage,
        title: String
    ) async throws -> (FacebookLiveVideo, StreamDestination) {
        let liveVideo = try await graph.createLiveVideo(
            pageID: page.id,
            pageAccessToken: page.accessToken,
            title: title
        )

        guard let destination = StreamDestinationFacebookParsing.destination(
            fromSecureStreamURL: liveVideo.secureStreamURL
        ) else {
            throw FacebookGraphError.apiError("URL RTMPS de Facebook inválida")
        }

        var updatedSession = session
        updatedSession.selectedPageID = page.id
        updatedSession.activeLiveVideoID = liveVideo.id
        FacebookSessionStore.save(updatedSession)

        EasyStreamLog.facebook.info("Facebook live prepared for page \(page.name, privacy: .public)")
        return (liveVideo, destination)
    }

    public func endLiveBroadcast(session: FacebookSession, page: FacebookPage) async throws {
        guard let liveVideoID = session.activeLiveVideoID else { return }
        try await graph.endLiveVideo(liveVideoID: liveVideoID, accessToken: page.accessToken)

        var updatedSession = session
        updatedSession.activeLiveVideoID = nil
        FacebookSessionStore.save(updatedSession)
        EasyStreamLog.facebook.info("Facebook live ended")
    }
}
