import Foundation

public enum FacebookConfiguration {
    public static let graphAPIVersion = "v21.0"

    public static var appID: String? {
        let value = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty, trimmed != "YOUR_FACEBOOK_APP_ID" else { return nil }
        return trimmed
    }

    public static let oauthRedirectURI = "https://www.facebook.com/connect/login_success.html"

    /// Initial login — always valid without extra Meta use cases.
    public static var basicOAuthScopeList: [String] {
        ["public_profile"]
    }

    /// Page + Live permissions — available only when the Page use case is configured in Meta.
    public static var pageOAuthScopeList: [String] {
        [
            "business_management",
            "pages_show_list",
            "pages_manage_posts",
            "pages_read_engagement",
        ]
    }

    public static var oauthScopeList: [String] {
        basicOAuthScopeList + pageOAuthScopeList
    }

    public static var oauthScopes: String {
        oauthScopeList.joined(separator: ",")
    }

    public static var clientToken: String? {
        let value = Bundle.main.object(forInfoDictionaryKey: "FacebookClientToken") as? String
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty, trimmed != "YOUR_FACEBOOK_CLIENT_TOKEN" else { return nil }
        return trimmed
    }

    public static var redirectURI: String? {
        oauthRedirectURI
    }

    /// iOS native SDK callback scheme (`fb` + App ID). macOS web login uses HTTPS redirect.
    public static var callbackURLScheme: String? {
        guard let appID else { return nil }
        return "fb\(appID)"
    }

    public static var isConfigured: Bool {
        appID != nil && clientToken != nil
    }

    public static let pagePermissionsMetaSetupHint = """
    Estás en «Facebook Login» — ahí NO están los permisos de Páginas.
    Ve al menú Dashboard (no Customize de Facebook Login) → Add use cases → elige «Manage everything on your Page» → Save.
    Luego abre ESE use case → Customize → Add: pages_manage_posts, pages_read_engagement, Live Video API.
    Si Add use cases no muestra Páginas, crea app nueva: Create App → Other → «Manage everything on your Page».
    """

    public static let createNewMetaAppHint = """
    Create App → Other → Next → «Manage everything on your Page» → Create.
    Settings → Basic → iOS (pabel.EasyStream.app) + Advanced (Client token) → actualiza Info.plist.
    """
}
