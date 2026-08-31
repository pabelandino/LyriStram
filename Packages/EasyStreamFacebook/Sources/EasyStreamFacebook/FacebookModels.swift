import Foundation

public struct FacebookUserProfile: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct FacebookPage: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let accessToken: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case accessToken = "access_token"
    }

    public init(id: String, name: String, accessToken: String) {
        self.id = id
        self.name = name
        self.accessToken = accessToken
    }
}

public struct FacebookLiveVideo: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let secureStreamURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case secureStreamURL = "secure_stream_url"
    }

    public init(id: String, secureStreamURL: String) {
        self.id = id
        self.secureStreamURL = secureStreamURL
    }
}

public struct FacebookSession: Codable, Sendable, Equatable {
    public var userAccessToken: String
    public var userProfile: FacebookUserProfile?
    public var selectedPageID: String?
    public var activeLiveVideoID: String?

    public init(
        userAccessToken: String = "",
        userProfile: FacebookUserProfile? = nil,
        selectedPageID: String? = nil,
        activeLiveVideoID: String? = nil
    ) {
        self.userAccessToken = userAccessToken
        self.userProfile = userProfile
        self.selectedPageID = selectedPageID
        self.activeLiveVideoID = activeLiveVideoID
    }

    public var isSignedIn: Bool {
        !userAccessToken.isEmpty
    }
}

public enum FacebookAuthError: Error, Sendable, LocalizedError {
    case appIDNotConfigured
    case clientTokenNotConfigured
    case nativeLoginNotConfigured
    case macOSLoginNotSupported
    case cancelled
    case invalidCallback
    case missingAccessToken
    case limitedLoginRequiresTracking
    case pagePermissionsNotConfigured
    case denied(String)
    case metaConfiguration(String)

    public var errorDescription: String? {
        switch self {
        case .appIDNotConfigured:
            "Configura FacebookAppID en Info.plist"
        case .clientTokenNotConfigured:
            "Configura FacebookClientToken en Info.plist (Meta → App settings → Advanced)"
        case .nativeLoginNotConfigured:
            "Facebook Login iOS no está enlazado. Añade EasyStreamFacebookLogin al target iOS."
        case .macOSLoginNotSupported:
            "Facebook Login no está soportado en Mac. Usa Director en iPad o iPhone."
        case .cancelled:
            "Inicio de sesión cancelado"
        case .invalidCallback:
            "Respuesta de Facebook inválida"
        case .missingAccessToken:
            "No se recibió token de acceso"
        case .limitedLoginRequiresTracking:
            """
            Facebook devolvió un login limitado (sin token de Graph API). Para usar Páginas y Live necesitas permitir rastreo:
            Ajustes → Privacidad → Rastreo → EasyStream → Activar.
            Luego cierra sesión en Facebook y vuelve a iniciar sesión en la app.
            """
        case .pagePermissionsNotConfigured:
            FacebookConfiguration.pagePermissionsMetaSetupHint
        case .denied(let reason):
            "Facebook denegó el acceso: \(reason)"
        case .metaConfiguration(let hint):
            hint
        }
    }
}

public enum FacebookGraphError: Error, Sendable, LocalizedError {
    case invalidResponse
    case apiError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Respuesta inválida de Graph API"
        case .apiError(let message):
            message
        }
    }
}
