import Foundation

@_silgen_name("esvb_native_bus_version")
private func esvb_native_bus_version() -> UnsafePointer<CChar>?

/// Swift façade over the C++ program frame bus (ring buffer, NV12 upload — phased rollout).
public enum ProgramFrameNativeCapabilities: Sendable {
    public static var busModuleVersion: String {
        guard let cString = esvb_native_bus_version() else {
            return "unavailable"
        }
        return String(cString: cString)
    }
}
