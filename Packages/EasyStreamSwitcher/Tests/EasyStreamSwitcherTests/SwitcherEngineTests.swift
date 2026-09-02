import Foundation
import Testing
import EasyStreamCore
@testable import EasyStreamSwitcher

@Test func cutChangesProgramAndAdvancesPreviewToPreviousProgram() async {
    let engine = SwitcherEngine()
    let camA = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
    let camB = CameraSourceID(UUID(uuidString: "00000000-0000-0000-0000-000000000002")!)

    _ = await engine.registerSource(camA)
    _ = await engine.registerSource(camB)
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
    _ = await engine.cut(to: camA)

    let events = await engine.unregisterSource(camA)
    let state = await engine.state

    #expect(state.programSourceID == camB)
    #expect(events.contains(where: {
        if case .programChanged(let id) = $0 { return id == camB }
        return false
    }))
}
