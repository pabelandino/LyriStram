import EasyStreamCore

/// What feeds program audio: a camera, the video on air, or a local interface.
enum DirectorProgramAudioInput: Hashable {
    case camera(CameraSourceID)
    case liveVideo
    case localDevice(String)
}
