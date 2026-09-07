import SwiftUI
import EasyStreamCore
#if os(macOS)
import AppKit
#endif

public struct BroadcastDraggableWidgetOverlay<Content: View>: View {
    @Binding var placement: BroadcastWidgetPlacement
    let isEditing: Bool
    let contentSizing: WidgetOverlayContentSizing
    let contentAspectRatio: CGFloat
    @ViewBuilder let content: () -> Content

    @State private var moveStartPlacement: BroadcastWidgetPlacement?
    @State private var resizeStartPlacement: BroadcastWidgetPlacement?
    @State private var isDragging = false

    private let minSize: CGFloat = 48

    public init(
        placement: Binding<BroadcastWidgetPlacement>,
        isEditing: Bool,
        contentSizing: WidgetOverlayContentSizing = .fillFrame,
        contentAspectRatio: CGFloat = 1,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._placement = placement
        self.isEditing = isEditing
        self.contentSizing = contentSizing
        self.contentAspectRatio = max(contentAspectRatio, 0.01)
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            let canvasSize = geometry.size
            let rect = WidgetPlacementGeometry.rect(
                from: placement,
                canvas: canvasSize,
                sizing: contentSizing
            )

            ZStack {
                content()
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .allowsHitTesting(false)

                if isEditing {
                    editingChrome(canvasSize: canvasSize, rect: rect)
                }
            }
        }
        .allowsHitTesting(isEditing)
    }

    @ViewBuilder
    private func editingChrome(canvasSize: CGSize, rect: CGRect) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .strokeBorder(Color.white.opacity(0.95), lineWidth: 1.5)
            .shadow(color: BroadcastTheme.studioAccent.opacity(0.35), radius: 6)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)

        Color.clear
            .frame(width: rect.width, height: rect.height)
            .contentShape(Rectangle())
            .position(x: rect.midX, y: rect.midY)
            .gesture(moveGesture(canvasSize: canvasSize))
#if os(macOS)
            .onHover { hovering in
                if hovering, !isDragging { NSCursor.openHand.push() }
                else { NSCursor.pop() }
            }
#endif

        ForEach(WidgetResizeCorner.allCases, id: \.self) { corner in
            WidgetCornerHandle()
                .frame(
                    width: WidgetPlacementChrome.handleHitSize,
                    height: WidgetPlacementChrome.handleHitSize
                )
                .contentShape(Rectangle())
                .position(x: corner.point(in: rect).x, y: corner.point(in: rect).y)
                .gesture(resizeGesture(canvasSize: canvasSize, corner: corner))
#if os(macOS)
                .onHover { hovering in
                    if hovering { corner.pushCursor() } else { NSCursor.pop() }
                }
#endif
        }
    }

    private func moveGesture(canvasSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .local)
            .onChanged { value in
                guard isEditing else { return }
                if moveStartPlacement == nil {
                    moveStartPlacement = placement
                    isDragging = true
#if os(macOS)
                    NSCursor.closedHand.push()
#endif
                }
                guard let start = moveStartPlacement else { return }
                var next = start
                next.normalizedCenterX = min(
                    1,
                    max(0, start.normalizedCenterX + Double(value.translation.width / canvasSize.width))
                )
                next.normalizedCenterY = min(
                    1,
                    max(0, start.normalizedCenterY + Double(value.translation.height / canvasSize.height))
                )
                placement = next
            }
            .onEnded { _ in
                moveStartPlacement = nil
                isDragging = false
#if os(macOS)
                NSCursor.pop()
#endif
            }
    }

    private func resizeGesture(canvasSize: CGSize, corner: WidgetResizeCorner) -> some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                guard isEditing else { return }
                if resizeStartPlacement == nil {
                    resizeStartPlacement = placement
                }
                guard let start = resizeStartPlacement else { return }
                placement = WidgetPlacementGeometry.resized(
                    from: start,
                    corner: corner,
                    translation: value.translation,
                    canvas: canvasSize,
                    sizing: contentSizing,
                    minSize: minSize
                )
            }
            .onEnded { _ in
                resizeStartPlacement = nil
            }
    }
}
