#if os(iOS)
import EasyStreamFacebook
import FacebookCore
import UIKit

@MainActor
public enum FacebookSDKBootstrap {
    public static func configure(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        applySettingsFromInfoPlist()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    @discardableResult
    public static func handleOpenURL(_ url: URL) -> Bool {
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }

    @discardableResult
    public static func handleOpenURL(
        _ application: UIApplication,
        url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation]
        )
    }

    private static func applySettingsFromInfoPlist() {
        if let appID = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String, !appID.isEmpty {
            Settings.shared.appID = appID
        }
        if let clientToken = Bundle.main.object(forInfoDictionaryKey: "FacebookClientToken") as? String, !clientToken.isEmpty {
            Settings.shared.clientToken = clientToken
        }
        if let displayName = Bundle.main.object(forInfoDictionaryKey: "FacebookDisplayName") as? String, !displayName.isEmpty {
            Settings.shared.displayName = displayName
        }
    }
}
#endif
