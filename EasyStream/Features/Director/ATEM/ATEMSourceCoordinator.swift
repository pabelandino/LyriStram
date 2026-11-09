import Foundation
import EasyStreamCore

/// Lists ATEM inputs beside the Wi-Fi cameras.
/// A simulated ATEM Mini stands in until Switchers SDK 11.0.1 answers ConnectTo.
@MainActor
final class ATEMSourceCoordinator {
    var onInputs: (([ATEMListedInput]) -> Void)?

    private var probeTask: Task<Void, Never>?
    private var showingHardware = false
    private var lastInputs: [ATEMListedInput] = []

    func start() {
        publish(ATEMListedInput.simulatedMini())
        guard ATEMSwitchersSDKBridge.sdkHeadersAvailable() else { return }
        ATEMSwitchersSDKBridge.start()
        probeTask = Task { [weak self] in
            while !Task.isCancelled {
                let snapshot = ATEMSwitchersSDKBridge.currentSnapshot()
                await self?.apply(snapshot)
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    func stop() {
        probeTask?.cancel()
        probeTask = nil
        showingHardware = false
        lastInputs = []
        ATEMSwitchersSDKBridge.stop()
    }

    private func apply(_ snapshot: [String: Any]?) {
        guard let snapshot, let rawInputs = snapshot["inputs"] as? [[String: Any]], !rawInputs.isEmpty else {
            if showingHardware {
                showingHardware = false
                publish(ATEMListedInput.simulatedMini())
            }
            return
        }
        let inputs = rawInputs.enumerated().compactMap { offset, item -> ATEMListedInput? in
            let inputID = (item["id"] as? NSNumber)?.int64Value ?? Int64(offset + 1)
            let port = ATEMVideoPort(rawValue: item["port"] as? String ?? "") ?? .other
            let shortName = (item["shortName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let displayName = shortName.isEmpty ? "\(port.title) \(offset + 1)" : shortName
            return ATEMListedInput(
                id: ATEMListedInput.hardwareID(inputID),
                displayName: displayName,
                port: port,
                isSimulated: false
            )
        }
        guard !inputs.isEmpty else { return }
        showingHardware = true
        publish(inputs)
    }

    private func publish(_ inputs: [ATEMListedInput]) {
        guard inputs != lastInputs else { return }
        lastInputs = inputs
        onInputs?(inputs)
    }
}
