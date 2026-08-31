import Testing
@testable import EasyStreamCore

@Test func appRoleServiceMapping() {
    #expect(AppRole.director.advertisedServiceType == .director)
    #expect(AppRole.camera.advertisedServiceType == .camera)
    #expect(AppRole.director.browsedServiceTypes == [.camera])
    #expect(AppRole.camera.browsedServiceTypes == [.director])
}

@Test func deviceIdentityPersistsID() {
    let first = DeviceIdentity.current(displayName: "Test Device")
    let second = DeviceIdentity.current(displayName: "Other Name")
    #expect(first.deviceID == second.deviceID)
}
