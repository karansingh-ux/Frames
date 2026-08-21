import Cocoa
import AppKit

public final class MenuBarController {
    public static let shared = MenuBarController()
    
    private var statusItem: NSStatusItem?
    
    private init() {}
    
    public func setupMenuBar() {
        guard statusItem == nil else { return }
        
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            if let image = NSImage(systemSymbolName: "viewfinder", accessibilityDescription: "Frames") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "⌗"
            }
        }
        
        let menu = NSMenu()
        
        let fullScreenItem = NSMenuItem(title: "Capture Full Screen", action: #selector(handleFullScreen), keyEquivalent: "")
        fullScreenItem.target = self
        menu.addItem(fullScreenItem)
        
        let areaItem = NSMenuItem(title: "Capture Area...", action: #selector(handleArea), keyEquivalent: "")
        areaItem.target = self
        menu.addItem(areaItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(handleSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        let updatesItem = NSMenuItem(title: "Check for Updates...", action: #selector(handleCheckForUpdates), keyEquivalent: "")
        updatesItem.target = self
        menu.addItem(updatesItem)
        
        let reportItem = NSMenuItem(title: "Report a Problem...", action: #selector(handleReportProblem), keyEquivalent: "")
        reportItem.target = self
        menu.addItem(reportItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit Frames", action: #selector(handleQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        item.menu = menu
        self.statusItem = item
    }
    
    @objc private func handleFullScreen() {
        AppState.shared.triggerFullScreenCapture()
    }
    
    @objc private func handleArea() {
        AppState.shared.triggerAreaCapture()
    }
    
    @objc private func handleSettings() {
        AppState.shared.openSettings()
    }
    
    @objc private func handleCheckForUpdates() {
        UpdateManager.shared.checkForUpdates(userInitiated: true)
    }
    
    @objc private func handleReportProblem() {
        FeedbackManager.shared.openProblemReportEmail()
    }
    
    @objc private func handleQuit() {
        NSApplication.shared.terminate(nil)
    }
}
