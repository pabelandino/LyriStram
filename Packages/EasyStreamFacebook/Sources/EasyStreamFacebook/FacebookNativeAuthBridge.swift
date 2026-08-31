import Foundation

public struct FacebookSignInRequest: Sendable {
    public let permissions: [String]
    public let rerequest: Bool
    public let clearSession: Bool

    public init(permissions: [String], rerequest: Bool = false, clearSession: Bool = true) {
        self.permissions = permissions
        self.rerequest = rerequest
        self.clearSession = clearSession
    }
}

public enum FacebookNativeAuthBridge {
    public typealias SignInHandler = @Sendable (FacebookSignInRequest) async throws -> String

    /// Set by `EasyStreamFacebookLogin` on iOS at app launch.
    public static var signIn: SignInHandler?
}
