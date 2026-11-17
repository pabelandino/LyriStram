import SwiftUI
import LvoqStreamCore

public struct PreviewMonitorHeaderBar: View {
    let cameraCount: Int
    let previewName: String?
    let programName: String?
    let layoutName: String
    let page: Int
    let pageCount: Int

    public init(
        cameraCount: Int,
        previewName: String?,
        programName: String?,
        layoutName: String,
        page: Int,
        pageCount: Int
    ) {
        self.cameraCount = cameraCount
        self.previewName = previewName
        self.programName = programName
        self.layoutName = layoutName
        self.page = page
        self.pageCount = pageCount
    }

    public var body: some View {
        HStack(spacing: 16) {
            Label(BundleLocalization.string("monitor.multiview.title"), systemImage: "rectangle.split.3x3")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text(String(format: BundleLocalization.string("monitor.camera_count"), cameraCount))
                .font(.caption)

            if let previewName {
                Text("\(BroadcastTerminology.previewShort): \(previewName)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }

            if let programName {
                Text("\(BroadcastTerminology.programShort): \(programName)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            }

            Spacer()

            Text(layoutName)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)

            if pageCount > 1 {
                Text(String(format: BundleLocalization.string("monitor.page_count"), page + 1, pageCount))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }
}