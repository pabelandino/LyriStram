import SwiftUI

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
            Label("MONITOR MULTIVIEW", systemImage: "rectangle.split.3x3")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text("\(cameraCount) cámara(s)")
                .font(.caption)

            if let previewName {
                Text("PVW: \(previewName)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }

            if let programName {
                Text("PRG: \(programName)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            }

            Spacer()

            Text(layoutName)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)

            if pageCount > 1 {
                Text("Pág. \(page + 1)/\(pageCount)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }
}
