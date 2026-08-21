import Cocoa
import AppKit
import FramesCore

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Prevent system from automatically terminating background menu bar app
        ProcessInfo.processInfo.disableAutomaticTermination("Frames persistent menu bar utility")
        
        // Configure Menu Bar item
        MenuBarController.shared.setupMenuBar()
        
        // Register Global Hotkeys from Preferences
        HotkeyManager.shared.registerAllFromPreferences()
        
        // Synchronize Launch at Login state if configured
        if AppPreferences.shared.launchAtLogin {
            LaunchAtLoginManager.shared.setEnabled(true)
        }
        
        // Check permissions on initial launch
        PermissionsManager.shared.checkPermissions()
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        // Cleanup any active panels or temporary state
    }
}
