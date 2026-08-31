import Testing
import EasyStreamCore
@testable import EasyStreamDiscovery

@Test func discoveryServiceStartsEmpty() async {
    let service = DiscoveryService()
    let devices = await service.discoveredDevices
    #expect(devices.isEmpty)
}
