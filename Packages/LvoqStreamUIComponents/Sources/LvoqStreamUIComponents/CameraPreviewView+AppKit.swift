#if canImport(AppKit)
import SwiftUI
import AppKit
import AVFoundation

public struct CameraPreviewView: NSViewRepresentable {
    let session: AVCaptureSession

    public init(session: AVCaptureSession) {
        self.session = session
    }

    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer = CALayer()
        view.wantsLayer = true
        view.layer?.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.previewLayer?.session = session
        context.coordinator.previewLayer?.frame = nsView.bounds
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    public final class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
#endif
