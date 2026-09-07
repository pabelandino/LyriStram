#if canImport(UIKit)
import SwiftUI
import UIKit
import AVFoundation

public struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    public init(session: AVCaptureSession) {
        self.session = session
    }

    public func makeUIView(context: Context) -> PreviewContainerView {
        let view = PreviewContainerView()
        view.configure(session: session)
        return view
    }

    public func updateUIView(_ uiView: PreviewContainerView, context: Context) {
        uiView.configure(session: session)
    }
}
#endif
