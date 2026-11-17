import CoreGraphics
import Metal

/// Supplies a premultiplied BGRA overlay texture composited on top of the program video bus.
@MainActor
protocol BroadcastMetalOverlayProvider: AnyObject {
    /// When true the compositor refreshes overlay snapshots at `overlayRefreshInterval`.
    var needsContinuousRefresh: Bool { get }
    var overlayRefreshInterval: TimeInterval { get }
    func overlayTexture(for viewportSize: CGSize, device: MTLDevice) -> MTLTexture?
}

extension BroadcastMetalOverlayProvider {
    var overlayRefreshInterval: TimeInterval { 1.0 / 30.0 }
}

/// No-op overlay — video-only output.
@MainActor
final class BroadcastMetalEmptyOverlayProvider: BroadcastMetalOverlayProvider {
    var needsContinuousRefresh: Bool { false }
    func overlayTexture(for viewportSize: CGSize, device: MTLDevice) -> MTLTexture? { nil }
}
