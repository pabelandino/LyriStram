import Foundation
import Testing
import EasyStreamCore
@testable import EasyStreamSwitcher

@Test func registerSourceDoesNotAutoArmPreview() async {
    let engine = SwitcherEngine()
    let camA = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

    let event = await engine.registerSource(camA)
    let state = await engine.state

    #expect(state.previewSourceID == nil)
    #expect(state.programSourceID == nil)
    #expect(event == .programAudioChanged(camA))
}

@Test func cutChangesProgramAndAdvancesPreviewToPreviousProgram() async {
    let engine = SwitcherEngine()
    let camA = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
    let camB = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000002")!)

    _ = await engine.registerSource(camA)
    _ = await engine.registerSource(camB)
    _ = await engine.setPreview(camA)
    _ = await engine.cut(to: camA)
    _ = await engine.setPreview(camB)

    let audioBefore = await engine.state.programAudioSourceID
    let events = await engine.cut(to: camB)

    let state = await engine.state
    #expect(state.programSourceID == camB)
    #expect(state.previewSourceID == camA)
    #expect(state.programAudioSourceID == audioBefore)
    #expect(events.count == 2)
}

@Test func programFallbackWhenActiveCameraDisconnects() async {
    let engine = SwitcherEngine()
    let camA = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
    let camB = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000002")!)

    _ = await engine.registerSource(camA)
    _ = await engine.registerSource(camB)
    _ = await engine.setPreview(camA)
    _ = await engine.cut(to: camA)

    let events = await engine.unregisterSource(camA)
    let state = await engine.state

    #expect(state.programSourceID == camB)
    #expect(events.contains(where: {
        if case .programChanged(let id) = $0 { return id == camB }
        return false
    }))
}

@Test func threeCameraTakeAdvancesPreviewToPreviousProgram() async {
    let engine = SwitcherEngine()
    let camA = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
    let camB = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000002")!)
    let camC = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000003")!)

    _ = await engine.registerSource(camA)
    _ = await engine.registerSource(camB)
    _ = await engine.registerSource(camC)
    _ = await engine.setPreview(camB)
    _ = await engine.cut(to: camB)
    _ = await engine.setPreview(camC)
    let events = await engine.cut(to: camC)

    let state = await engine.state
    #expect(state.programSourceID == camC)
    #expect(state.previewSourceID == camB)
    #expect(events.contains(where: {
        if case .programChanged(let id) = $0 { return id == camC }
        return false
    }))
    #expect(events.contains(where: {
        if case .previewChanged(let id) = $0 { return id == camB }
        return false
    }))
}

@Test func firstTakeSelectsOtherCameraAsPreview() async {
    let engine = SwitcherEngine()
    let camA = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
    let camB = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000002")!)

    _ = await engine.registerSource(camA)
    _ = await engine.registerSource(camB)
    _ = await engine.setPreview(camB)

    let events = await engine.cut(to: camB)
    let state = await engine.state

    #expect(state.programSourceID == camB)
    #expect(state.previewSourceID == camA)
    #expect(events.contains(where: {
        if case .previewChanged(let id) = $0 { return id == camA }
        return false
    }))
}

@Test func idleSourcesUnchangedWhenPreviewSelectsAmongMany() async {
    let engine = SwitcherEngine()
    let cameras = (1...5).map {
        CameraSourceID(UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", $0))!)
    }

    for camera in cameras {
        _ = await engine.registerSource(camera)
    }

    for camera in cameras.dropFirst() {
        let event = await engine.setPreview(camera)
        #expect(event == .previewChanged(camera))
        let state = await engine.state
        #expect(state.previewSourceID == camera)
        #expect(state.programSourceID == nil)
    }
}
