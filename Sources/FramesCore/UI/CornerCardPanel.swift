import Cocoa
import SwiftUI
import AppKit

public final class CornerCardPanel: NSPanel {
    private var hostingView: NSHostingView<StackContainerView>?
    private var targetDisplayID: CGDirectDisplayID
    
    public init(appState: AppState, displayID: CGDirectDisplayID = CGMainDisplayID()) {
        self.targetDisplayID = displayID
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 850),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .floating
        self.hasShadow = false
        self.isMovable = false
        self.ignoresMouseEvents = false
        self.acceptsMouseMovedEvents = true
        self.isReleasedWhenClosed = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        
        let rootView = StackContainerView(appState: appState)
        let hosting = NSHostingView(rootView: rootView)
        hosting.autoresizingMask = [.width, .height]
        self.hostingView = hosting
        self.contentView = hosting
        
        updateLayout(isExpanded: appState.isExpanded, count: appState.activeScreenshots.count, displayID: displayID, animate: false)
    }
    
    public func updateLayout(isExpanded: Bool, count: Int, displayID: CGDirectDisplayID? = nil, animate: Bool = false) {
        if let dID = displayID {
            self.targetDisplayID = dID
        }
        
        guard let screen = NSScreen.screens.first(where: {
            guard let idNum = $0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return false }
            return idNum.uint32Value == self.targetDisplayID
        }) ?? NSScreen.main else {
            return
        }
        
        let visibleFrame = screen.visibleFrame
        let cardWidth: CGFloat = 220
        let cardHeight: CGFloat = 150
        let arrowWidth: CGFloat = 36
        let padding: CGFloat = 20
        
        // Fixed, stable window geometry so window origin NEVER moves or jumps on new captures
        let panelWidth: CGFloat = cardWidth + arrowWidth + 12 + (padding * 2)
        let panelHeight: CGFloat = (5.0 * cardHeight) + (4.0 * 12.0) + (padding * 2)
        
        // Exact fixed 24px margin from screen bottom and right edges
        let x = visibleFrame.maxX - panelWidth - (24.0 - padding)
        let y = visibleFrame.minY + (24.0 - padding)
        
        let targetFrame = NSRect(x: x, y: y, width: panelWidth, height: panelHeight)
        if self.frame != targetFrame {
            self.setFrame(targetFrame, display: true, animate: false)
        }
    }
}
