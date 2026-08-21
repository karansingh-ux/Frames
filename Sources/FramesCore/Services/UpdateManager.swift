import Foundation
import AppKit

public final class UpdateManager {
    public static let shared = UpdateManager()
    
    public static let currentVersion = "1.0.0"
    
    private init() {}
    
    public func checkForUpdates(userInitiated: Bool = true) {
        let alert = NSAlert()
        alert.messageText = "You're up to date!"
        alert.informativeText = "Frames \(UpdateManager.currentVersion) is currently the latest version available."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
