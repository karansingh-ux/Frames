import SwiftUI
import AppKit

public struct MultiItemDragSource<Content: View>: NSViewRepresentable {
    let items: () -> [ScreenshotItem]
    let content: Content
    
    public init(items: @escaping () -> [ScreenshotItem], @ViewBuilder content: () -> Content) {
        self.items = items
        self.content = content()
    }
    
    public func makeNSView(context: Context) -> MultiItemDragNSView {
        let view = MultiItemDragNSView()
        view.getItems = items
        
        let hosting = NSHostingView(rootView: content)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting)
        view.hostingView = hosting
        
        NSLayoutConstraint.activate([
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    
    public func updateNSView(_ nsView: MultiItemDragNSView, context: Context) {
        nsView.getItems = items
        if let hosting = nsView.hostingView as? NSHostingView<Content> {
            hosting.rootView = content
        }
    }
}

public final class MultiItemDragNSView: NSView, NSDraggingSource {
    var getItems: (() -> [ScreenshotItem])?
    var hostingView: NSView?
    private var panGesture: NSPanGestureRecognizer?
    private var draggedItems: [ScreenshotItem] = []
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupGesture()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGesture()
    }
    
    private func setupGesture() {
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delaysPrimaryMouseButtonEvents = false
        pan.buttonMask = 0x1 // Left mouse button
        self.addGestureRecognizer(pan)
        self.panGesture = pan
    }
    
    @objc private func handlePan(_ gesture: NSPanGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let event = NSApp.currentEvent else { return }
        
        startNativeDrag(with: event)
    }
    
    public func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
    
    public func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        let windowFrame = self.window?.frame ?? .zero
        let droppedOutside = !NSMouseInRect(screenPoint, windowFrame, false)
        
        // If the drop completed or was dropped outside the Frames preview card window
        if operation != [] || droppedOutside {
            let itemsToRemove = self.draggedItems
            // Allow 600ms grace period so target applications (ChatGPT, Claude, Slack, Figma, browsers)
            // have sufficient time to finish streaming the image data before the preview card unmounts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                for item in itemsToRemove {
                    AppState.shared.deleteScreenshot(item)
                }
            }
            self.draggedItems.removeAll()
        } else {
            self.draggedItems.removeAll()
        }
    }
    
    private func startNativeDrag(with event: NSEvent) {
        guard let items = getItems?(), !items.isEmpty else { return }
        
        self.draggedItems = items
        var draggingItems: [NSDraggingItem] = []
        let writers = DragDropManager.shared.prepareDragItems(for: items)
        let total = items.count
        
        let localPoint = self.convert(event.locationInWindow, from: nil)
        let dragFrame = NSRect(x: localPoint.x - 110, y: localPoint.y - 75, width: 220, height: 150)
        
        for (index, item) in items.enumerated() {
            guard index < writers.count else { continue }
            let writer = writers[index]
            
            let dragItem = NSDraggingItem(pasteboardWriter: writer)
            let previewImage = DragDropManager.shared.createDragPreview(for: item.cgImage, totalCount: total, index: index)
            
            dragItem.setDraggingFrame(dragFrame, contents: previewImage)
            draggingItems.append(dragItem)
        }
        
        self.beginDraggingSession(with: draggingItems, event: event, source: self)
    }
}
