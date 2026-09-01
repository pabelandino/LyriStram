import Foundation
import Network
import EasyStreamCore

/// Primes the system Local Network permission sheet by browsing Bonjour on the `local.` domain only.
public actor LocalNetworkPermissionTrigger {
    public static let shared = LocalNetworkPermissionTrigger()

    private var browsers: [NWBrowser] = []
    private let queue = DispatchQueue(label: "com.easystream.local-network-prime", qos: .userInitiated)

    private init() {}

    /// Call while the app is in the foreground before other Bonjour work so macOS/iOS can show the permission dialog.
    public func primeForPermissionPrompt() {
        guard browsers.isEmpty else { return }

        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        for serviceType in BonjourServiceType.allCases {
            let descriptor = NWBrowser.Descriptor.bonjourWithTXTRecord(
                type: serviceType.networkType,
                domain: NetworkConstants.serviceDomain
            )
            let browser = NWBrowser(for: descriptor, using: parameters)
            browser.start(queue: queue)
            browsers.append(browser)
        }
    }

    public func stop() {
        for browser in browsers {
            browser.cancel()
        }
        browsers.removeAll()
    }
}
