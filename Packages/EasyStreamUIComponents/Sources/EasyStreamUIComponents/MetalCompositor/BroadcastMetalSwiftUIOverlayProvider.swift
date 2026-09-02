import Metal
import SwiftUI
import EasyStreamCore

/// Renders SwiftUI widget overlays into a BGRA texture for `BroadcastMetalCompositor`.
/// Must be called on the main thread (`ImageRenderer` requirement).
@MainActor
final class BroadcastMetalSwiftUIOverlayProvider: BroadcastMetalOverlayProvider {
    var widgetLayers: [ProgramFeedWidgetLayer] = []
    var fullScreenResource: BroadcastResource?
    var fullScreenFileURL: URL?
    var fullScreenIsLive = false
    var onWidgetLiveAutoDismiss: ((UUID) -> Void)?

    private var cachedTexture: MTLTexture?
    private var cachedViewport: CGSize = .zero
    private var cachedSignature: String = ""

    var needsContinuousRefresh: Bool {
        BroadcastMetalWidgetOverlayContent.needsContinuousRefresh(for: widgetLayers)
            || (fullScreenIsLive && fullScreenResource != nil)
    }

    var overlayRefreshInterval: TimeInterval { 1.0 / 15.0 }

    func overlayTexture(for viewportSize: CGSize, device: MTLDevice) -> MTLTexture? {
        guard viewportSize.width > 1, viewportSize.height > 1 else { return nil }
        guard !widgetLayers.isEmpty || fullScreenResource != nil else {
            cachedTexture = nil
            cachedSignature = ""
            return nil
        }

        let signature = contentSignature(viewportSize: viewportSize)
        if signature == cachedSignature, let cachedTexture, cachedViewport == viewportSize {
            return cachedTexture
        }

        let content = BroadcastMetalWidgetOverlayContent(
            widgetLayers: widgetLayers,
            fullScreenResource: fullScreenResource,
            fullScreenFileURL: fullScreenFileURL,
            fullScreenIsLive: fullScreenIsLive,
            onWidgetLiveAutoDismiss: onWidgetLiveAutoDismiss
        )
        .frame(width: viewportSize.width, height: viewportSize.height)
        .background(Color.clear)

        let renderer = ImageRenderer(content: content)
        renderer.isOpaque = false
        renderer.proposedSize = ProposedViewSize(viewportSize)
#if os(iOS)
        renderer.scale = UIScreen.main.scale
#else
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2
#endif

        guard let cgImage = renderer.cgImage else { return cachedTexture }
        guard let texture = BroadcastMetalTextureUploader.makeTexture(from: cgImage, device: device) else {
            return cachedTexture
        }

        cachedTexture = texture
        cachedViewport = viewportSize
        cachedSignature = signature
        return texture
    }

    func invalidateCache() {
        cachedTexture = nil
        cachedSignature = ""
    }

    func syncContentSignature(viewportSize: CGSize) -> String {
        contentSignature(viewportSize: viewportSize)
    }

    private func contentSignature(viewportSize: CGSize) -> String {
        let layerIDs = widgetLayers.map(\.id.uuidString).joined(separator: "|")
        let configs = widgetLayers.map { "\($0.id)-\($0.configuration.revisionToken)-\($0.isLive)" }
            .joined(separator: "|")
        return [
            String(format: "%.0fx%.0f", viewportSize.width, viewportSize.height),
            layerIDs,
            configs,
            fullScreenResource?.id.uuidString ?? "none",
            fullScreenIsLive ? "live" : "idle",
            needsContinuousRefresh ? String(Int(Date().timeIntervalSinceReferenceDate * 15)) : "static"
        ].joined(separator: ";")
    }
}

private extension BroadcastWidgetConfiguration {
    var revisionToken: String {
        [
            resolvedTemplate.rawValue,
            title,
            subtitle ?? "",
            tickerText,
            countdownSeconds.description,
            countdownTargetDate?.timeIntervalSince1970.description ?? "none"
        ].joined(separator: ":")
    }
}

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif
