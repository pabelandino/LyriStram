#if canImport(UIKit)
import UIKit
import AVFoundation
import EasyStreamCameraCapture

public final class PreviewContainerView: UIView {
    private let previewLayer = AVCaptureVideoPreviewLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
        previewLayer.connection?.applyCurrentVideoOrientationIfSupported()
    }

    func configure(session: AVCaptureSession) {
        previewLayer.session = session
        previewLayer.connection?.applyCurrentVideoOrientationIfSupported()
    }
}
#endif
