import Cocoa
import SwiftUI
import AppKit

public final class CornerCardPanel: NSPanel {
    private var hostingView: NSHostingView<StackContainerView>?
    private var targetDisplayID: CGDirectDisplayID
    
    public init(appState: AppState, displayID: CGDirectDisplayID = CGMainDisplayID()) {
        self.targetDisplayID = displayID
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 240),
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
    
    public func updateLayout(isExpanded: Bool, count: Int, displayID: CGDirectDisplayID? = nil, animate: Bool = true) {
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
        let effectiveCount = max(1, count)
        
        let panelWidth: CGFloat
        let panelHeight: CGFloat
        
        if isExpanded && effectiveCount > 1 {
            // Expanded vertically upward
            panelWidth = cardWidth + arrowWidth + 12 + (padding * 2)
            panelHeight = CGFloat(effectiveCount) * cardHeight + CGFloat(effectiveCount - 1) * 12.0 + (padding * 2)
        } else if effectiveCount > 1 {
            // Collapsed stack of 2..5 cards
            let cascadeShift = CGFloat(effectiveCount - 1) * 8.0
            panelWidth = cardWidth + cascadeShift + arrowWidth + 12 + (padding * 2)
            panelHeight = cardHeight + cascadeShift + (padding * 2)
        } else {
            // Single card
            panelWidth = cardWidth + (padding * 2)
            panelHeight = cardHeight + (padding * 2)
        }
        
        // Exact 24px margin from screen bottom and right edges (accounting for 20px transparent inner padding)
        let x = visibleFrame.maxX - panelWidth - (24.0 - padding)
        let y = visibleFrame.minY + (24.0 - padding)
        
        let newFrame = NSRect(x: x, y: y, width: panelWidth, height: panelHeight)
        self.setFrame(newFrame, display: true, animate: animate)
    }
}
