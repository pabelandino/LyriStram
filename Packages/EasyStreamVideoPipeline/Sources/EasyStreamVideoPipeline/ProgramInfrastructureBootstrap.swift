import EasyStreamCore
import EasyStreamVideoBusNative

/// Wires domain ports to live infrastructure adapters at app launch.
public enum ProgramInfrastructureBootstrap {
    public static func installLiveAdapters() {
        ProgramFrameTelemetryRegistry.install(ProgramFrameBus.shared)
        _ = ProgramFrameDisplayBus.shared
        _ = ProgramFrameNativeCapabilities.busModuleVersion
    }
}
