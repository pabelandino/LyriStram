import Foundation
import Observation
import OSLog
import EasyStreamCore
import EasyStreamDiscovery

@MainActor
@Observable
public final class DiscoveryViewModel {
    public private(set) var devices: [DiscoveredDevice] = []
    public private(set) var isRunning = false
    public private(set) var statusMessage = "Iniciando…"
    public private(set) var needsLocalNetworkPermission = false
    public private(set) var lastError: String?

    private let discovery = DiscoveryService()
    private var eventTask: Task<Void, Never>?

    public init() {}

    public func start(role: AppRole, identity: DeviceIdentity) {
        guard !isRunning else { return }

        eventTask?.cancel()
        eventTask = Task { [discovery] in
            let stream = await discovery.events()
            for await event in stream {
                guard !Task.isCancelled else { break }
                await MainActor.run {
                    self.handle(event)
                }
            }
        }

        Task {
            do {
                try await discovery.start(role: role, identity: identity)
                isRunning = true
                statusMessage = role == .director
                    ? "Buscando cámaras en la red local…"
                    : "Buscando directores en la red local…"
                await refreshDevices()
            } catch {
                lastError = error.localizedDescription
                statusMessage = "Error al iniciar discovery"
                EasyStreamLog.discovery.error("Start failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    public func stop() {
        eventTask?.cancel()
        eventTask = nil
        Task {
            await discovery.stop()
            isRunning = false
            devices = []
            statusMessage = "Detenido"
        }
    }

    private func handle(_ event: DiscoveryEvent) {
        switch event {
        case .deviceAppeared, .deviceUpdated, .deviceRemoved:
            Task { await refreshDevices() }
        case .browsingFailed(let message), .advertisingFailed(let message):
            lastError = message
            statusMessage = message
        case .localNetworkPermissionRequired:
            needsLocalNetworkPermission = true
            statusMessage = "Permiso de red local requerido"
        }
    }

    private func refreshDevices() async {
        devices = await discovery.discoveredDevices
        if !devices.isEmpty {
            statusMessage = "\(devices.count) dispositivo(s) encontrado(s)"
        }
    }
}
