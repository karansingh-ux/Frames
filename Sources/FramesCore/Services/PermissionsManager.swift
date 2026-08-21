import Foundation
import CoreGraphics
import AppKit
import ApplicationServices

public final class PermissionsManager: ObservableObject {
    public static let shared = PermissionsManager()
    
    public var hasScreenCapturePermission: Bool {
        return CGPreflightScreenCaptureAccess()
    }
    
    public var hasAccessibilityPermission: Bool {
        return AXIsProcessTrusted()
    }
    
    private init() {}
    
    public func checkPermissions() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    @discardableResult
    public func requestScreenCapturePermission() -> Bool {
        let granted = CGRequestScreenCaptureAccess()
        checkPermissions()
        return granted
    }
    
    public func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options)
        checkPermissions()
    }
    
    public func openScreenCaptureSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
    
    public func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
