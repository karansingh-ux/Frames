import Cocoa
import AppKit

public final class AreaSelectionOverlayWindow: NSPanel {
    private var selectionView: AreaSelectionView?
    
    public init(screen: NSScreen, onSelect: @escaping (CGRect, CGDirectDisplayID) -> Void, onCancel: @escaping () -> Void) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .screenSaver // High level above all windows
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.acceptsMouseMovedEvents = true
        self.isReleasedWhenClosed = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        guard let idNum = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return
        }
        let displayID = idNum.uint32Value
        
        let view = AreaSelectionView(frame: NSRect(origin: .zero, size: screen.frame.size), screenFrame: screen.frame, displayID: displayID, onSelect: onSelect, onCancel: onCancel)
        self.selectionView = view
        self.contentView = view
    }
    
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { true }
}

public final class AreaSelectionManager {
    public static let shared = AreaSelectionManager()
    private var overlayWindows: [AreaSelectionOverlayWindow] = []
    
    private init() {}
    
    public func startSelection(onCompletion: @escaping (CGRect?, CGDirectDisplayID?) -> Void) {
        cancelSelection()
        
        for screen in NSScreen.screens {
            let window = AreaSelectionOverlayWindow(
                screen: screen,
                onSelect: { [weak self] rect, displayID in
                    self?.cancelSelection()
                    onCompletion(rect, displayID)
                },
                onCancel: { [weak self] in
                    self?.cancelSelection()
                    onCompletion(nil, nil)
                }
            )
            overlayWindows.append(window)
            window.makeKeyAndOrderFront(nil)
        }
        
        NSCursor.crosshair.push()
    }
    
    public func cancelSelection() {
        NSCursor.pop()
        for window in overlayWindows {
            window.orderOut(nil)
        }
        overlayWindows.removeAll()
    }
}

public final class AreaSelectionView: NSView {
    private let screenFrame: NSRect
    private let displayID: CGDirectDisplayID
    private let onSelect: (CGRect, CGDirectDisplayID) -> Void
    private let onCancel: () -> Void
    
    private var startPoint: NSPoint?
    private var currentPoint: NSPoint?
    
    public init(frame: NSRect, screenFrame: NSRect, displayID: CGDirectDisplayID, onSelect: @escaping (CGRect, CGDirectDisplayID) -> Void, onCancel: @escaping () -> Void) {
        self.screenFrame = screenFrame
        self.displayID = displayID
        self.onSelect = onSelect
        self.onCancel = onCancel
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override var acceptsFirstResponder: Bool { true }
    
    public override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC
            onCancel()
        } else {
            super.keyDown(with: event)
        }
    }
    
    public override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = startPoint
        needsDisplay = true
    }
    
    public override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }
    
    public override func mouseUp(with event: NSEvent) {
        guard let start = startPoint, let current = currentPoint else {
            onCancel()
            return
        }
        
        let rect = rectFromPoints(start, current)
        if rect.width > 4 && rect.height > 4 {
            SoundManager.shared.playShutterSound()
            onSelect(rect, displayID)
        } else {
            onCancel()
        }
        
        startPoint = nil
        currentPoint = nil
        needsDisplay = true
    }
    
    private func rectFromPoints(_ p1: NSPoint, _ p2: NSPoint) -> NSRect {
        let x = min(p1.x, p2.x)
        let y = min(p1.y, p2.y)
        let width = abs(p1.x - p2.x)
        let height = abs(p1.y - p2.y)
        return NSRect(x: x, y: y, width: width, height: height)
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // Dim the entire view
        context.setFillColor(NSColor.black.withAlphaComponent(0.25).cgColor)
        context.fill(bounds)
        
        if let start = startPoint, let current = currentPoint {
            let selectionRect = rectFromPoints(start, current)
            
            // Clear the selected area
            context.setBlendMode(.clear)
            context.fill(selectionRect)
            
            // Restore blend mode for border & HUD
            context.setBlendMode(.normal)
            
            // Stroke selection border
            context.setStrokeColor(NSColor.white.cgColor)
            context.setLineWidth(1.5)
            context.stroke(selectionRect)
            
            // Outer subtle shadow/glow border
            context.setStrokeColor(NSColor.black.withAlphaComponent(0.4).cgColor)
            context.setLineWidth(0.5)
            context.stroke(selectionRect.insetBy(dx: -1, dy: -1))
            
            // Dimension badge HUD
            let dimensionText = "\(Int(selectionRect.width)) × \(Int(selectionRect.height))"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium),
                .foregroundColor: NSColor.white
            ]
            let textSize = (dimensionText as NSString).size(withAttributes: attributes)
            let badgeRect = NSRect(
                x: selectionRect.midX - (textSize.width + 16) / 2,
                y: max(10, selectionRect.minY - 26),
                width: textSize.width + 16,
                height: 20
            )
            
            let badgePath = NSBezierPath(roundedRect: badgeRect, xRadius: 4, yRadius: 4)
            NSColor.black.withAlphaComponent(0.75).setFill()
            badgePath.fill()
            
            let textPoint = NSPoint(x: badgeRect.origin.x + 8, y: badgeRect.origin.y + 3)
            (dimensionText as NSString).draw(at: textPoint, withAttributes: attributes)
        }
    }
}
