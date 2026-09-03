import EasyStreamVideoBusNative

/// Exposes C++ bus module status to the application layer without importing native headers in UI.
public enum ProgramFrameNativeStatus: Sendable {
    public static var moduleVersion: String {
        ProgramFrameNativeCapabilities.busModuleVersion
    }
}
