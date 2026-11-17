import Testing
import LvoqStreamCore
@testable import LvoqStreamDiscovery

@Test func discoveryServiceStartsEmpty() async {
    let service = DiscoveryService()
    let devices = await service.discoveredDevices
    #expect(devices.isEmpty)
}
