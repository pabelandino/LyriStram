import Foundation
import Network
import OSLog
import LvoqStreamCore

/// Subscribes to the Lvoq Show lyric service and keeps the live text feed current.
@MainActor
final class LvoqShowAirClient {
    static let shared = LvoqShowAirClient()

    private var browser: NWBrowser?
    private var connection: NWConnection?
    private var reader: LineReader?
    private var loopbackTask: Task<Void, Never>?
    private let queue = DispatchQueue(label: "com.lvoqstream.lvoqshow.air", qos: .userInitiated)
    private var connectedName: String?
    private var connectionGeneration = 0

    private init() {}

    func start() {
        guard browser == nil else { return }
        LvoqShowAirFeed.shared.link = .searching
        startLoopback()
        let services = (Bundle.main.object(forInfoDictionaryKey: "NSBonjourServices") as? [String])?.joined(separator: ", ") ?? "none"
        LvoqStreamLog.lvoqshow.info("NSBonjourServices \(services, privacy: .public)")
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        let descriptor = "\(LvoqShowAir.bonjourType).\(LvoqShowAir.bonjourDomain)"
        LvoqStreamLog.lvoqshow.info("Browsing \(descriptor, privacy: .public)")
        let browser = NWBrowser(
            for: .bonjourWithTXTRecord(type: LvoqShowAir.bonjourType, domain: LvoqShowAir.bonjourDomain),
            using: parameters
        )
        browser.browseResultsChangedHandler = { results, changes in
            let endpoint = results.first?.endpoint
            let summary = results.map { "\($0.endpoint)" }.sorted().joined(separator: " | ")
            let changeCount = changes.count
            let resultCount = results.count
            Task { @MainActor in
                LvoqStreamLog.lvoqshow.info("Browse \(resultCount) results, \(changeCount) changes: \(summary, privacy: .public)")
                LvoqShowAirClient.shared.connect(to: endpoint)
            }
        }
        browser.stateUpdateHandler = { state in
            let label = lvoqshowBrowserState(state)
            Task { @MainActor in
                LvoqStreamLog.lvoqshow.info("Browser \(label, privacy: .public)")
                if case .failed = state {
                    LvoqStreamLog.lvoqshow.error("Bonjour browse denied; keeping loopback 127.0.0.1:\(LvoqShowAir.loopbackPort, privacy: .public)")
                    LvoqShowAirClient.shared.retireDeniedBrowser()
                    if LvoqShowAirClient.shared.connection == nil {
                        LvoqShowAirFeed.shared.link = .searching
                    }
                }
            }
        }
        browser.start(queue: queue)
        self.browser = browser
    }

    /// Direct path for LvoqShow running on this Mac. mDNS can reject a service type it has not refreshed yet.
    private func startLoopback() {
        loopbackTask?.cancel()
        loopbackTask = Task { @MainActor in
            while !Task.isCancelled {
                if connection == nil, let port = NWEndpoint.Port(rawValue: LvoqShowAir.loopbackPort) {
                    LvoqStreamLog.lvoqshow.info("Loopback 127.0.0.1:\(LvoqShowAir.loopbackPort, privacy: .public)")
                    connect(to: .hostPort(host: "127.0.0.1", port: port))
                }
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    func stop() {
        LvoqStreamLog.lvoqshow.info("Air client stopped")
        loopbackTask?.cancel()
        loopbackTask = nil
        browser?.cancel()
        browser = nil
        connection?.cancel()
        connection = nil
        reader = nil
        connectedName = nil
        LvoqShowAirFeed.shared.link = .idle
        LvoqShowAirFeed.shared.frame = .clear
    }

    /// A denied browse stays registered with mDNS and stalls the camera browsers.
    private func retireDeniedBrowser() {
        browser?.cancel()
        browser = nil
    }

    private func connect(to endpoint: NWEndpoint?) {
        guard let endpoint else {
            LvoqStreamLog.lvoqshow.info("Browse returned no endpoint")
            return
        }
        // Replacing a live socket drops the lyric feed and wakes the network stack again.
        if connection != nil {
            return
        }
        LvoqStreamLog.lvoqshow.info("Connecting to \(String(describing: endpoint), privacy: .public)")
        connectionGeneration &+= 1
        let generation = connectionGeneration
        connection?.cancel()
        let connection = NWConnection(to: endpoint, using: .tcp)
        let reader = LineReader { frame in
            Task { @MainActor in
                guard LvoqShowAirClient.shared.connectionGeneration == generation else { return }
                LvoqShowAirClient.shared.receive(frame)
            }
        } onClose: {
            Task { @MainActor in
                guard LvoqShowAirClient.shared.connectionGeneration == generation else { return }
                LvoqShowAirClient.shared.noteDisconnect()
            }
        }
        connection.stateUpdateHandler = { state in
            let label = lvoqshowConnectionState(state)
            Task { @MainActor in
                guard LvoqShowAirClient.shared.connectionGeneration == generation else { return }
                LvoqStreamLog.lvoqshow.info("Connection \(label, privacy: .public)")
                switch state {
                case .ready:
                    LvoqShowAirFeed.shared.link = .connected
                    LvoqShowAirClient.shared.sendSubscribe(on: connection)
                case .failed, .cancelled:
                    LvoqShowAirClient.shared.noteDisconnect()
                default:
                    break
                }
            }
        }
        connection.start(queue: queue)
        reader.start(on: connection, queue: queue)
        self.connection = connection
        self.reader = reader
        if case .service(let name, _, _, _) = endpoint {
            connectedName = name
        }
    }

    private func sendSubscribe(on connection: NWConnection) {
        let envelope = LvoqShowSyncEnvelope(kind: "subscribeAir", air: nil)
        guard var payload = try? JSONEncoder().encode(envelope) else {
            LvoqStreamLog.lvoqshow.error("Failed to encode subscribeAir")
            return
        }
        payload.append(0x0A)
        let bytes = payload.count
        connection.send(content: payload, completion: .contentProcessed { error in
            if let error {
                LvoqStreamLog.lvoqshow.error("subscribeAir send failed: \(error.localizedDescription, privacy: .public)")
            } else {
                LvoqStreamLog.lvoqshow.info("subscribeAir sent (\(bytes) bytes)")
            }
        })
    }

    private func receive(_ frame: LvoqShowAirFrame) {
        guard connection != nil else { return }
        LvoqStreamLog.lvoqshow.info("Frame revision \(frame.revision) content \(frame.content.rawValue, privacy: .public) active \(frame.active) chars \(frame.body.count)")
        LvoqShowAirFeed.shared.link = .connected
        guard frame != LvoqShowAirFeed.shared.frame else { return }
        LvoqShowAirFeed.shared.frame = frame
    }

    private func noteDisconnect() {
        guard browser != nil else { return }
        LvoqStreamLog.lvoqshow.info("Air socket closed; still browsing")
        connection = nil
        reader = nil
        connectedName = nil
        LvoqShowAirFeed.shared.link = .searching
    }
}

private nonisolated func lvoqshowBrowserState(_ state: NWBrowser.State) -> String {
    switch state {
    case .setup: "setup"
    case .ready: "ready"
    case .cancelled: "cancelled"
    case .failed(let error): "failed \(error.localizedDescription)"
    case .waiting(let error): "waiting \(error.localizedDescription)"
    @unknown default: "unknown"
    }
}

private nonisolated func lvoqshowConnectionState(_ state: NWConnection.State) -> String {
    switch state {
    case .setup: "setup"
    case .waiting(let error): "waiting \(error.localizedDescription)"
    case .preparing: "preparing"
    case .ready: "ready"
    case .failed(let error): "failed \(error.localizedDescription)"
    case .cancelled: "cancelled"
    @unknown default: "unknown"
    }
}

private nonisolated struct LvoqShowSyncEnvelope: Codable {
    var kind: String
    var air: LvoqShowAirFrame?
}

private final class LineReader: @unchecked Sendable {
    private var buffer = Data()
    private let onFrame: @Sendable (LvoqShowAirFrame) -> Void
    private let onClose: @Sendable () -> Void
    private let decoder = JSONDecoder()

    init(onFrame: @escaping @Sendable (LvoqShowAirFrame) -> Void, onClose: @escaping @Sendable () -> Void) {
        self.onFrame = onFrame
        self.onClose = onClose
    }

    func start(on connection: NWConnection, queue: DispatchQueue) {
        receive(on: connection, queue: queue)
    }

    private func receive(on connection: NWConnection, queue: DispatchQueue) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65_536) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            if let error {
                LvoqStreamLog.lvoqshow.error("Air read failed: \(error.localizedDescription, privacy: .public)")
                self.onClose()
                return
            }
            if let data {
                self.buffer.append(data)
            }
            while let newline = self.buffer.firstIndex(of: 0x0A) {
                let line = Data(self.buffer[..<newline])
                self.buffer.removeSubrange(...newline)
                guard !line.isEmpty else { continue }
                do {
                    let envelope = try self.decoder.decode(LvoqShowSyncEnvelope.self, from: line)
                    if envelope.kind == "airFrame", let frame = envelope.air {
                        self.onFrame(frame)
                    } else {
                        LvoqStreamLog.lvoqshow.info("Ignored line kind \(envelope.kind, privacy: .public)")
                    }
                } catch {
                    let preview = String(data: line.prefix(160), encoding: .utf8) ?? "<binary>"
                    LvoqStreamLog.lvoqshow.error("Air line decode failed: \(error.localizedDescription, privacy: .public) \(preview, privacy: .public)")
                }
            }
            if isComplete {
                self.onClose()
                return
            }
            self.receive(on: connection, queue: queue)
        }
    }
}
