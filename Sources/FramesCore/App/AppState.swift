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
    private var annotationWindow: NSWindow?
    private var settingsWindow: NSWindow?
    
    public var activeOverlayWindowIDs: [CGWindowID] {
        var ids: [CGWindowID] = []
        if let panel = cornerPanel {
            ids.append(CGWindowID(panel.windowNumber))
        }
        if let annot = annotationWindow {
            ids.append(CGWindowID(annot.windowNumber))
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
        
        AreaSelectionManager.shared.startSelection { [weak self] rect, displayID in
            guard let self = self, let rect = rect, let displayID = displayID else { return }
            
            Task { @MainActor in
                do {
                    let image = try await CaptureEngine.shared.captureRect(rect, displayID: displayID, excludedWindowIDs: self.activeOverlayWindowIDs)
                    self.playCaptureSound()
                    self.addScreenshot(cgImage: image, displayID: displayID)
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
    
    public func toggleExpanded() {
        isExpanded.toggle()
        cornerPanel?.updateLayout(isExpanded: isExpanded, count: activeScreenshots.count, animate: true)
    }
    
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
    
    public func copyScreenshot(_ item: ScreenshotItem) {
        ClipboardManager.shared.copyImageToClipboard(item.cgImage)
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
        activeScreenshots.removeAll(where: { $0.id == item.id })
        
        if activeScreenshots.isEmpty {
            isExpanded = false
            cornerPanel?.orderOut(nil)
            DragDropManager.shared.purgeAllCache()
        } else {
            if activeScreenshots.count <= 1 {
                isExpanded = false
            }
            cornerPanel?.updateLayout(isExpanded: isExpanded, count: activeScreenshots.count, animate: true)
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
            cornerPanel?.updateLayout(isExpanded: isExpanded, count: activeScreenshots.count, displayID: displayID, animate: true)
        }
        cornerPanel?.makeKeyAndOrderFront(nil)
    }
    
    // MARK: - Modals & Windows
    
    public func openEditor(for item: ScreenshotItem) {
        item.stopTimer() // Pause timer while editing
        
        let view = AnnotationView(
            item: item,
            onSaveAndDismiss: { [weak self] editedImage in
                self?.annotationWindow?.orderOut(nil)
                self?.annotationWindow = nil
                self?.deleteScreenshot(item)
                _ = DesktopSaver.shared.saveImageToDisk(editedImage)
                self?.showToast("Saved Annotated Image")
            },
            onCancel: { [weak self] in
                self?.annotationWindow?.orderOut(nil)
                self?.annotationWindow = nil
                item.startTimer()
            }
        )
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Annotate Screenshot"
        window.center()
        window.contentView = NSHostingView(rootView: view)
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        self.annotationWindow = window
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
