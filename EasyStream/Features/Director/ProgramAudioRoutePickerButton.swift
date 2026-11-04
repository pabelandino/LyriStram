import SwiftUI

#if os(iOS)
import AVKit
import UIKit

/// System route picker so the operator can monitor on headphones or AirPlay.
struct ProgramAudioRoutePickerButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.tintColor = UIColor.secondaryLabel
        picker.prioritizesVideoDevices = false
        return picker
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
#else
struct ProgramAudioRoutePickerButton: View {
    var body: some View {
        EmptyView()
    }
}
#endif
