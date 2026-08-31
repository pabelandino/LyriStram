import EasyStreamFacebook
import AppTrackingTransparency
import FacebookCore
import FacebookLogin
import UIKit

@MainActor
public enum FacebookPlatformAuth {
    public static func signIn(request: FacebookSignInRequest) async throws -> String {
        if request.clearSession {
            LoginManager().logOut()
            await requestTrackingAuthorizationIfNeeded()
        }

        return try await withCheckedThrowingContinuation { continuation in
            guard let configuration = LoginConfiguration(
                permissions: request.permissions,
                tracking: .enabled,
                messengerPageId: nil,
                authType: request.rerequest ? .rerequest : nil
            ) else {
                continuation.resume(throwing: FacebookPlatformAuthError.invalidConfiguration)
                return
            }

            guard let presenter = topViewController() else {
                continuation.resume(throwing: FacebookPlatformAuthError.missingPresenter)
                return
            }

            LoginManager().logIn(viewController: presenter, configuration: configuration) { result in
                switch result {
                case .failed(let error):
                    continuation.resume(throwing: error)
                case .cancelled:
                    continuation.resume(throwing: FacebookPlatformAuthError.cancelled)
                case .success(_, _, let token):
                    do {
                        let accessToken = try Self.resolveGraphAccessToken(from: token)
                        continuation.resume(returning: accessToken)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    private static func requestTrackingAuthorizationIfNeeded() async {
        guard #available(iOS 14, *) else { return }
        _ = await ATTrackingManager.requestTrackingAuthorization()
    }

    private static func resolveGraphAccessToken(from resultToken: AccessToken?) throws -> String {
        if AuthenticationToken.current != nil, AccessToken.current == nil, resultToken == nil {
            throw FacebookPlatformAuthError.limitedLoginOnly
        }

        guard let tokenString = (AccessToken.current ?? resultToken)?.tokenString,
              !tokenString.isEmpty else {
            throw FacebookPlatformAuthError.missingAccessToken
        }

        if Self.looksLikeAuthenticationJWT(tokenString) {
            throw FacebookPlatformAuthError.limitedLoginOnly
        }

        return tokenString
    }

    private static func looksLikeAuthenticationJWT(_ token: String) -> Bool {
        let parts = token.split(separator: ".")
        return parts.count == 3 && token.hasPrefix("eyJ")
    }

    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        let window = scenes
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)

        var controller = window?.rootViewController
        while let presented = controller?.presentedViewController {
            controller = presented
        }
        return controller
    }
}

enum FacebookPlatformAuthError: Error, Sendable {
    case invalidConfiguration
    case missingPresenter
    case cancelled
    case missingAccessToken
    case limitedLoginOnly
}

public enum EasyStreamFacebookLoginSetup {
    public static func install() {
        FacebookNativeAuthBridge.signIn = { request in
            do {
                return try await FacebookPlatformAuth.signIn(request: request)
            } catch let error as FacebookPlatformAuthError {
                switch error {
                case .cancelled:
                    throw FacebookAuthError.cancelled
                case .missingAccessToken:
                    throw FacebookAuthError.missingAccessToken
                case .limitedLoginOnly:
                    throw FacebookAuthError.limitedLoginRequiresTracking
                case .invalidConfiguration, .missingPresenter:
                    throw FacebookAuthError.invalidCallback
                }
            }
        }
    }
}
