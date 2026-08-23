import Foundation
import SwiftUI
import CoreGraphics
import AppKit
import AudioToolbox

public final class AppState: ObservableObject {
    public static let shared = AppState()
    
    @Published public var activeScreenshots: [ScreenshotItem] = []
    @Published public var isExpanded: Bool = false
    @Published public var showLimitAlert: Bool = false
    @Published public var activeToastMessage: String?
    
    public var cornerPanel: CornerCardPanel?
    private var openAnnotationWindows: [UUID: NSWindow] = [:]
    private var settingsWindow: NSWindow?
    
    public var activeOverlayWindowIDs: [CGWindowID] {
        var ids: [CGWindowID] = []
        if let panel = cornerPanel {
            ids.append(CGWindowID(panel.windowNumber))
        }
        for (_, window) in openAnnotationWindows {
            ids.append(CGWindowID(window.windowNumber))
        }
        if let settings = settingsWindow {
            ids.append(CGWindowID(settings.windowNumber))
        }
        return ids
    }
    
    private init() {}
    
    // MARK: - Captures
    
    public func triggerFullScreenCapture() {
        guard activeScreenshots.count < 5 else {
            showLimitReachedAlert()
            return
        }
        
        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) }) ?? NSScreen.main
        guard let idNum = targetScreen?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return
        }
        let displayID = idNum.uint32Value
        
        Task { @MainActor in
            do {
                let image = try await CaptureEngine.shared.captureFullScreen(displayID: displayID, excludedWindowIDs: self.activeOverlayWindowIDs)
                self.playCaptureSound()
                self.addScreenshot(cgImage: image, displayID: displayID)
            } catch {
                NSLog("[Frames] Full screen capture failed: \(error.localizedDescription)")
                if !PermissionsManager.shared.hasScreenCapturePermission {
                    PermissionsManager.shared.requestScreenCapturePermission()
                    PermissionsManager.shared.openScreenCaptureSettings()
                    self.showToast("Please allow Screen Recording in System Settings")
                }
            }
        }
    }
    
    public func triggerAreaCapture() {
        guard activeScreenshots.count < 5 else {
            showLimitReachedAlert()
            return
        }
        
        AreaSelectionManager.shared.startSelection { [weak self] selectedRect, displayID in
            guard let self = self, let rect = selectedRect, let dID = displayID else {
                return
            }
            
            Task { @MainActor in
                do {
                    let image = try await CaptureEngine.shared.captureRect(rect, displayID: dID, excludedWindowIDs: self.activeOverlayWindowIDs)
                    self.playCaptureSound()
                    self.addScreenshot(cgImage: image, displayID: dID)
                } catch {
                    NSLog("[Frames] Area capture failed: \(error.localizedDescription)")
                    if !PermissionsManager.shared.hasScreenCapturePermission {
                        PermissionsManager.shared.requestScreenCapturePermission()
                        PermissionsManager.shared.openScreenCaptureSettings()
                        self.showToast("Please allow Screen Recording in System Settings")
                    }
                }
            }
        }
    }
    
    private func playCaptureSound() {
        guard AppPreferences.shared.playSoundOnCapture else { return }
        NSSound(named: "Grab")?.play()
    }
    
    // MARK: - Stack Management
    
    public func addScreenshot(cgImage: CGImage, displayID: CGDirectDisplayID) {
        let action = AppPreferences.shared.afterScreenshot
        switch action {
        case .copy:
            ClipboardManager.shared.copyImageToClipboard(cgImage)
            showToast("Copied to Clipboard")
        case .save:
            if DesktopSaver.shared.saveImageToDisk(cgImage) != nil {
                let folderName = URL(fileURLWithPath: AppPreferences.shared.saveDirectoryPath).lastPathComponent
                showToast("Saved to \(folderName)")
            }
        case .show:
            let item = ScreenshotItem(cgImage: cgImage, displayID: displayID) { [weak self] expiredItem in
                self?.handleAutoSave(for: expiredItem)
            }
            activeScreenshots.append(item)
            showCornerPanel(for: displayID)
        }
    }
    
    public func toggleExpanded() {
        isExpanded.toggle()
        cornerPanel?.updateLayout(isExpanded: isExpanded, count: activeScreenshots.count, animate: false)
    }
    
    public func copyScreenshot(_ item: ScreenshotItem) {
        ClipboardManager.shared.copyImageToClipboard(item.cgImage)
        showToast("Copied to Clipboard")
        deleteScreenshot(item)
    }
    
    public func saveScreenshot(_ item: ScreenshotItem) {
        if DesktopSaver.shared.saveImageToDisk(item.cgImage) != nil {
            showToast("Saved to Desktop")
        }
        deleteScreenshot(item)
    }
    
    public func deleteScreenshot(_ item: ScreenshotItem) {
        item.stopTimer()
        DragDropManager.shared.removeCache(for: item)
        
        // If an editor window was open for this item, close it
        if let window = openAnnotationWindows.removeValue(forKey: item.id) {
            window.orderOut(nil)
        }
        
        activeScreenshots.removeAll(where: { $0.id == item.id })
        
        if activeScreenshots.isEmpty {
            isExpanded = false
            cornerPanel?.orderOut(nil)
            DragDropManager.shared.purgeAllCache()
        } else {
            if activeScreenshots.count <= 1 {
                isExpanded = false
            }
            cornerPanel?.updateLayout(isExpanded: isExpanded, count: activeScreenshots.count, animate: false)
        }
    }
    
    private func handleAutoSave(for item: ScreenshotItem) {
        _ = DesktopSaver.shared.saveImageToDisk(item.cgImage)
        showToast("Auto-saved to Desktop")
        deleteScreenshot(item)
    }
    
    private func showLimitReachedAlert() {
        showLimitAlert = true
        if cornerPanel == nil {
            showCornerPanel(for: CGMainDisplayID())
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            self?.showLimitAlert = false
        }
    }
    
    public func showToast(_ message: String) {
        activeToastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            if self?.activeToastMessage == message {
                self?.activeToastMessage = nil
            }
        }
    }
    
    private func showCornerPanel(for displayID: CGDirectDisplayID) {
        if cornerPanel == nil {
            cornerPanel = CornerCardPanel(appState: self, displayID: displayID)
        } else {
            cornerPanel?.updateLayout(isExpanded: isExpanded, count: activeScreenshots.count, displayID: displayID, animate: false)
        }
        cornerPanel?.makeKeyAndOrderFront(nil)
    }
    
    // MARK: - Modals & Windows
    
    public func openEditor(for item: ScreenshotItem) {
        // If an editor window is already open for this specific screenshot, bring it to front
        if let existing = openAnnotationWindows[item.id] {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        item.stopTimer() // Pause 60s timer while editing
        
        let view = AnnotationView(
            item: item,
            onSaveAndDismiss: { [weak self] editedImage in
                guard let self = self else { return }
                if let window = self.openAnnotationWindows.removeValue(forKey: item.id) {
                    window.orderOut(nil)
                }
                self.deleteScreenshot(item)
                _ = DesktopSaver.shared.saveImageToDisk(editedImage)
                self.showToast("Saved Annotated Image")
            },
            onCancel: { [weak self] in
                guard let self = self else { return }
                if let window = self.openAnnotationWindows.removeValue(forKey: item.id) {
                    window.orderOut(nil)
                }
                item.startTimer()
            }
        )
        
        // Calculate appropriate initial window size based on screenshot dimensions
        let imgWidth = CGFloat(item.cgImage.width)
        let imgHeight = CGFloat(item.cgImage.height)
        let aspectRatio = imgWidth / max(1.0, imgHeight)
        
        var winWidth: CGFloat = 800
        var winHeight: CGFloat = 600
        if aspectRatio > 1.0 {
            winWidth = min(1000, max(720, imgWidth / 2.0))
            winHeight = min(750, (winWidth / aspectRatio) + 60)
        } else {
            winHeight = min(800, max(600, imgHeight / 2.0))
            winWidth = min(800, (winHeight - 60) * aspectRatio)
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: winWidth, height: winHeight),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Annotate Screenshot"
        window.center()
        window.contentView = NSHostingView(rootView: view)
        window.isReleasedWhenClosed = false
        window.level = .floating // Float above ordinary windows so it is immediately visible
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        self.openAnnotationWindows[item.id] = window
    }
    
    public func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 430),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Frames Settings"
        window.center()
        window.contentView = NSHostingView(rootView: SettingsView())
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.settingsWindow = window
    }
}
