import Foundation
import Network
import EasyStreamCore

/// Manages Bonjour advertisement and browsing for EasyStream devices on the local network.
public actor DiscoveryService {
    private var role: AppRole?
    private var identity: DeviceIdentity?
    private var listener: NWListener?
    private var browsers: [BonjourServiceType: NWBrowser] = [:]
    private var devices: [UUID: DiscoveredDevice] = [:]
    private var pendingEndpoints: [String: NWEndpoint] = [:]
    private var continuation: AsyncStream<DiscoveryEvent>.Continuation?
    private var ownDeviceID: UUID?
    private var incomingConnectionHandler: (@Sendable (NWConnection) -> Void)?

    public init() {}

    /// Director role: handle inbound TCP connections (signaling) from cameras.
    public func setIncomingConnectionHandler(_ handler: (@Sendable (NWConnection) -> Void)?) {
        incomingConnectionHandler = handler
    }

    public var discoveredDevices: [DiscoveredDevice] {
        Array(devices.values).sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }

    public func events() -> AsyncStream<DiscoveryEvent> {
        AsyncStream { continuation in
            self.continueEvents(continuation)
        }
    }

    private func continueEvents(_ continuation: AsyncStream<DiscoveryEvent>.Continuation) {
        self.continuation = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.stop() }
        }
    }

    public func start(role: AppRole, identity: DeviceIdentity) async throws {
        await stop()

        self.role = role
        self.identity = identity
        self.ownDeviceID = identity.deviceID

        await LocalNetworkPermissionTrigger.shared.primeForPermissionPrompt()

        try await startAdvertising(role: role, identity: identity)
        startBrowsing(for: role)
    }

    public func stop() async {
        for browser in browsers.values {
            browser.cancel()
        }
        browsers.removeAll()
        listener?.cancel()
        listener = nil
        pendingEndpoints.removeAll()
        await LocalNetworkPermissionTrigger.shared.stop()

        let removedIDs = devices.keys
        devices.removeAll()
        for id in removedIDs {
            emit(.deviceRemoved(id))
        }
    }

    // MARK: - Advertising

    private func startAdvertising(role: AppRole, identity: DeviceIdentity) async throws {
        let parameters = NWParameters.tcp
        parameters.includePeerToPeer = true

        let txtRecord = BonjourTXTCodec.makeRecord(identity: identity, role: role)
        let serviceType = role.advertisedServiceType.networkType

        // Bonjour service names should stay ASCII-safe; human-readable name lives in TXT.
        let bonjourName = "ES-\(identity.deviceID.uuidString.prefix(8))"
        let service = NWListener.Service(
            name: bonjourName,
            type: serviceType,
            domain: NetworkConstants.serviceDomain,
            txtRecord: txtRecord
        )

        let listener = try NWListener(service: service, using: parameters)
        self.listener = listener

        listener.serviceRegistrationUpdateHandler = { change in
            switch change {
            case .add(let endpoint):
                EasyStreamLog.discovery.debug("Registered Bonjour service at \(String(describing: endpoint), privacy: .public)")
            default:
                break
            }
        }

        listener.stateUpdateHandler = { [weak self] state in
            Task { await self?.handleListenerState(state) }
        }

        listener.newConnectionHandler = { [weak self] connection in
            Task {
                await self?.handleIncomingConnection(connection)
            }
        }

        listener.start(queue: .global(qos: .userInitiated))
        EasyStreamLog.discovery.info("Advertising \(serviceType, privacy: .public) as \(identity.displayName, privacy: .public)")
    }

    private func handleListenerState(_ state: NWListener.State) {
        switch state {
        case .ready:
            EasyStreamLog.discovery.debug("Listener ready")
        case .failed(let error):
            EasyStreamLog.discovery.error("Listener failed: \(error.localizedDescription, privacy: .public)")
            if isLocalNetworkPermissionError(error) {
                emit(.localNetworkPermissionRequired)
            } else {
                emit(.advertisingFailed(error.localizedDescription))
            }
        case .cancelled:
            EasyStreamLog.discovery.debug("Listener cancelled")
        default:
            break
        }
    }

    // MARK: - Browsing

    private func startBrowsing(for role: AppRole) {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        for serviceType in role.browsedServiceTypes {
            // Explicitly request TXT record resolution — required for metadata on iOS.
            let descriptor = NWBrowser.Descriptor.bonjourWithTXTRecord(
                type: serviceType.networkType,
                domain: NetworkConstants.serviceDomain
            )
            let browser = NWBrowser(for: descriptor, using: parameters)

            browser.stateUpdateHandler = { [weak self] state in
                Task { await self?.handleBrowserState(state, serviceType: serviceType) }
            }

            browser.browseResultsChangedHandler = { [weak self] results, changes in
                Task { await self?.handleBrowseResults(results: results, changes: changes, serviceType: serviceType) }
            }

            browser.start(queue: .global(qos: .userInitiated))
            browsers[serviceType] = browser
            EasyStreamLog.discovery.info("Browsing for \(serviceType.rawValue, privacy: .public)")
        }
    }

    private func handleBrowserState(_ state: NWBrowser.State, serviceType: BonjourServiceType) {
        switch state {
        case .ready:
            EasyStreamLog.discovery.debug("Browser ready for \(serviceType.rawValue, privacy: .public)")
        case .failed(let error):
            EasyStreamLog.discovery.error("Browser failed: \(error.localizedDescription, privacy: .public)")
            if isLocalNetworkPermissionError(error) {
                emit(.localNetworkPermissionRequired)
            } else {
                emit(.browsingFailed(error.localizedDescription))
            }
        case .cancelled:
            EasyStreamLog.discovery.debug("Browser cancelled for \(serviceType.rawValue, privacy: .public)")
        default:
            break
        }
    }

    private func handleBrowseResults(
        results: Set<NWBrowser.Result>,
        changes: Set<NWBrowser.Result.Change>,
        serviceType: BonjourServiceType
    ) {
        for change in changes {
            if case .removed(let result) = change {
                removeDevice(matching: result, serviceType: serviceType)
            }
        }

        // Always reconcile the full result set so TXT metadata picked up on
        // `.changed(metadataChanged)` is not missed after an initial `.added`.
        for result in results {
            upsertDevice(from: result, serviceType: serviceType)
        }
    }

    private func upsertDevice(from result: NWBrowser.Result, serviceType: BonjourServiceType) {
        let endpointKey = "\(result.endpoint)"
        let txtRecord = txtRecord(from: result)

        guard let parsed = BonjourTXTCodec.decode(txtRecord) else {
            if BonjourTXTCodec.isEmpty(txtRecord) {
                pendingEndpoints[endpointKey] = result.endpoint
                EasyStreamLog.discovery.debug("Awaiting TXT metadata for \(endpointKey, privacy: .public)")
            } else {
                EasyStreamLog.discovery.debug("TXT record present but incomplete for \(endpointKey, privacy: .public)")
            }
            return
        }

        pendingEndpoints.removeValue(forKey: endpointKey)

        if parsed.deviceID == ownDeviceID {
            return
        }

        if let existing = devices[parsed.deviceID],
           existing.serviceType.isSignalingService,
           serviceType == .intercom {
            EasyStreamLog.discovery.debug(
                "Ignoring intercom browse update for signaling device \(parsed.displayName, privacy: .public)"
            )
            return
        }

        let device = DiscoveredDevice(
            id: parsed.deviceID,
            endpoint: result.endpoint,
            serviceType: serviceType,
            displayName: parsed.displayName,
            platform: parsed.platform,
            protocolVersion: parsed.protocolVersion,
            role: parsed.role,
            state: .discovered
        )

        let isNew = devices[parsed.deviceID] == nil
        let previous = devices[parsed.deviceID]
        devices[parsed.deviceID] = device

        if isNew {
            EasyStreamLog.discovery.info("Discovered \(parsed.displayName, privacy: .public) [\(parsed.role.rawValue, privacy: .public)]")
            emit(.deviceAppeared(device))
        } else if previous != device {
            emit(.deviceUpdated(device))
        }
    }

    private func removeDevice(matching result: NWBrowser.Result, serviceType: BonjourServiceType) {
        let endpointKey = "\(result.endpoint)"
        pendingEndpoints.removeValue(forKey: endpointKey)

        if let parsed = BonjourTXTCodec.decode(txtRecord(from: result)) {
            if let existing = devices[parsed.deviceID], existing.serviceType != serviceType {
                return
            }
            devices.removeValue(forKey: parsed.deviceID)
            emit(.deviceRemoved(parsed.deviceID))
            return
        }

        if let id = devices.first(where: { $0.value.endpoint == result.endpoint && $0.value.serviceType == serviceType })?.key {
            devices.removeValue(forKey: id)
            emit(.deviceRemoved(id))
        }
    }

    private func txtRecord(from result: NWBrowser.Result) -> NWTXTRecord? {
        if case .bonjour(let record) = result.metadata {
            return record
        }
        return nil
    }

    private func emit(_ event: DiscoveryEvent) {
        continuation?.yield(event)
    }

    private func isLocalNetworkPermissionError(_ error: NWError) -> Bool {
        error.isEasyStreamLocalNetworkPermissionIssue
    }

    private func handleIncomingConnection(_ connection: NWConnection) {
        if let incomingConnectionHandler {
            incomingConnectionHandler(connection)
        } else {
            connection.cancel()
        }
    }
}
