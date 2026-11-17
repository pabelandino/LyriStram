import CoreAudio
import Foundation

#if os(macOS)

/// One Core Audio device the director can use as a program input or monitor output.
struct MacAudioDevice: Equatable, Sendable {
    let id: AudioDeviceID
    let uid: String
    let name: String
    let inputChannels: Int
    let outputChannels: Int
}

/// Lists hardware audio devices and applies the ones the operator picks.
enum MacAudioDeviceCatalog {
    private static var savedDefaultOutput: AudioDeviceID?

    static func devices() -> [MacAudioDevice] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        let system = AudioObjectID(kAudioObjectSystemObject)
        guard AudioObjectGetPropertyDataSize(system, &address, 0, nil, &size) == noErr, size > 0 else {
            return []
        }
        let count = Int(size) / MemoryLayout<AudioDeviceID>.size
        var ids = [AudioDeviceID](repeating: 0, count: count)
        guard AudioObjectGetPropertyData(system, &address, 0, nil, &size, &ids) == noErr else {
            return []
        }
        return ids.compactMap { id in
            guard let uid = stringProperty(kAudioDevicePropertyDeviceUID, device: id),
                  let name = stringProperty(kAudioDevicePropertyDeviceNameCFString, device: id) else {
                return nil
            }
            let inputs = channelCount(device: id, scope: kAudioObjectPropertyScopeInput)
            let outputs = channelCount(device: id, scope: kAudioObjectPropertyScopeOutput)
            guard inputs > 0 || outputs > 0 else { return nil }
            return MacAudioDevice(id: id, uid: uid, name: name, inputChannels: inputs, outputChannels: outputs)
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    static func deviceID(uid: String) -> AudioDeviceID? {
        devices().first { $0.uid == uid }?.id
    }

    static func setDefaultOutput(uid: String) {
        guard let id = deviceID(uid: uid) else { return }
        if savedDefaultOutput == nil {
            savedDefaultOutput = currentDefaultOutput()
        }
        setDefaultDevice(id, selector: kAudioHardwarePropertyDefaultOutputDevice)
    }

    static func restoreDefaultOutput() {
        guard let saved = savedDefaultOutput else { return }
        setDefaultDevice(saved, selector: kAudioHardwarePropertyDefaultOutputDevice)
    }

    static func currentOutputName() -> String {
        guard let id = currentDefaultOutput(),
              let name = stringProperty(kAudioDevicePropertyDeviceNameCFString, device: id) else {
            return "Salida del sistema"
        }
        return name
    }

    private static func currentDefaultOutput() -> AudioDeviceID? {
        var id = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &id) == noErr,
              id != 0 else {
            return nil
        }
        return id
    }

    private static func setDefaultDevice(_ id: AudioDeviceID, selector: AudioObjectPropertySelector) {
        var deviceID = id
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let size = UInt32(MemoryLayout<AudioDeviceID>.size)
        AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, size, &deviceID)
    }

    private static func stringProperty(_ selector: AudioObjectPropertySelector, device: AudioDeviceID) -> String? {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var value: Unmanaged<CFString>?
        var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        guard AudioObjectGetPropertyData(device, &address, 0, nil, &size, &value) == noErr,
              let value else {
            return nil
        }
        return value.takeRetainedValue() as String
    }

    private static func channelCount(device: AudioDeviceID, scope: AudioObjectPropertyScope) -> Int {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: scope,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(device, &address, 0, nil, &size) == noErr, size > 0 else {
            return 0
        }
        let raw = UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: MemoryLayout<AudioBufferList>.alignment)
        defer { raw.deallocate() }
        guard AudioObjectGetPropertyData(device, &address, 0, nil, &size, raw) == noErr else {
            return 0
        }
        let buffers = UnsafeMutableAudioBufferListPointer(raw.assumingMemoryBound(to: AudioBufferList.self))
        return buffers.reduce(0) { $0 + Int($1.mNumberChannels) }
    }
}
#endif
