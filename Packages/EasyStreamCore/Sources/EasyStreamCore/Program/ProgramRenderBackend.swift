import Foundation

/// Presentation backend for the director program monitor video surface.
public enum ProgramRenderBackend: String, Sendable, CaseIterable {
    /// Single MTKView compositor (Phase 1+).
    case metalCompositor
    /// Legacy dual RTCMTLVideoView crossfade (deprecated — fallback only).
    case legacyDualWebRTC
}

/// Application-level render configuration injected at composition root.
public struct ProgramRenderConfiguration: Sendable {
    public var backend: ProgramRenderBackend
    public var previewVisibility: ProgramPreviewVisibilityPolicy

    public init(
        backend: ProgramRenderBackend = .metalCompositor,
        previewVisibility: ProgramPreviewVisibilityPolicy = .directorDefault
    ) {
        self.backend = backend
        self.previewVisibility = previewVisibility
    }

    public static let production = ProgramRenderConfiguration()
}
