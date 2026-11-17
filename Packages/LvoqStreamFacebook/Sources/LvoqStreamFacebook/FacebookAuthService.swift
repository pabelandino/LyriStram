import Foundation

#if os(macOS)
import AppKit
import WebKit
#endif

@MainActor
public final class FacebookAuthService {
    public static let shared = FacebookAuthService()

    private init() {}

    public func signIn(request: FacebookSignInRequest) async throws -> String {
#if os(iOS)
        guard let signIn = FacebookNativeAuthBridge.signIn else {
            throw FacebookAuthError.nativeLoginNotConfigured
        }
        do {
            return try await signIn(request)
        } catch {
            throw Self.mapIOSError(error)
        }
#elseif os(macOS)
        throw FacebookAuthError.macOSLoginNotSupported
#else
        throw FacebookAuthError.nativeLoginNotConfigured
#endif
    }

    public func signIn() async throws -> String {
        try await signIn(
            request: FacebookSignInRequest(
                permissions: FacebookConfiguration.basicOAuthScopeList,
                clearSession: true
            )
        )
    }

    public func authorizePages() async throws -> String {
        try await signIn(
            request: FacebookSignInRequest(
                permissions: FacebookConfiguration.pageOAuthScopeList,
                rerequest: true,
                clearSession: false
            )
        )
    }

#if os(iOS)
    private static func mapIOSError(_ error: Error) -> Error {
        let message = error.localizedDescription
        if message.localizedCaseInsensitiveContains("not allowed by the application configuration")
            || message.localizedCaseInsensitiveContains("valid native platform") {
            let bundleID = Bundle.main.bundleIdentifier ?? "unknown"
            return FacebookAuthError.metaConfiguration(
                """
                Meta rechazó el redirect de la app. En developers.facebook.com:
                1) Settings → Basic → Add Platform → iOS
                2) Bundle ID exacto: \(bundleID)
                3) Guarda cambios y espera 2 min
                4) En el menú lateral: Use cases → Facebook Login (debe estar activo)
                No uses redirect URIs manuales para iOS nativo.
                """
            )
        }
        return error
    }
#endif

#if os(macOS)
    private func buildManualAuthURL() throws -> URL {
        guard let appID = FacebookConfiguration.appID else {
            throw FacebookAuthError.appIDNotConfigured
        }

        var components = URLComponents(string: "https://www.facebook.com/\(FacebookConfiguration.graphAPIVersion)/dialog/oauth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: appID),
            URLQueryItem(name: "redirect_uri", value: FacebookConfiguration.oauthRedirectURI),
            URLQueryItem(name: "scope", value: FacebookConfiguration.oauthScopes),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "display", value: "touch"),
        ]

        guard let url = components.url else {
            throw FacebookAuthError.invalidCallback
        }
        return url
    }
#endif
}

enum FacebookTokenParser {
    static func parseAccessToken(from url: URL) throws -> String {
        let fragment = url.fragment ?? url.query ?? ""
        let params = parseKeyValuePairs(fragment)

        if let error = params["error"] {
            let reason = params["error_description"] ?? params["error_reason"] ?? error
            throw FacebookAuthError.denied(reason)
        }

        guard let token = params["access_token"], !token.isEmpty else {
            throw FacebookAuthError.missingAccessToken
        }
        return token
    }

    private static func parseKeyValuePairs(_ value: String) -> [String: String] {
        var result: [String: String] = [:]
        for pair in value.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            let key = parts[0].removingPercentEncoding ?? parts[0]
            let val = parts[1].removingPercentEncoding ?? parts[1]
            result[key] = val
        }
        return result
    }
}

#if os(macOS)
@MainActor
final class FacebookWebLoginSession: NSObject, WKNavigationDelegate {
    static let shared = FacebookWebLoginSession()

    private var webView: WKWebView?
    private var continuation: CheckedContinuation<String, Error>?
    private var window: NSWindow?

    func start(url: URL) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            presentWebView(loading: url)
        }
    }

    private func presentWebView(loading url: URL) {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        self.webView = webView

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 640),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Facebook Login"
        window.contentView = webView
        window.delegate = self
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
        webView.load(URLRequest(url: url))
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if Self.isLoginSuccessURL(url) {
            decisionHandler(.cancel)
            do {
                let token = try FacebookTokenParser.parseAccessToken(from: url)
                finish(with: .success(token))
            } catch {
                finish(with: .failure(error))
            }
            return
        }

        decisionHandler(.allow)
    }

    private func finish(with result: Result<String, Error>) {
        switch result {
        case .success(let token):
            continuation?.resume(returning: token)
        case .failure(let error):
            continuation?.resume(throwing: error)
        }
        continuation = nil
        dismiss()
    }

    private func dismiss() {
        window?.close()
        window = nil
        webView?.navigationDelegate = nil
        webView = nil
    }

    private static func isLoginSuccessURL(_ url: URL) -> Bool {
        url.host == "www.facebook.com" && url.path == "/connect/login_success.html"
    }
}

extension FacebookWebLoginSession: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if continuation != nil {
            finish(with: .failure(FacebookAuthError.cancelled))
        }
    }
}
#endif
