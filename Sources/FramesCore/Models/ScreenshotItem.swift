import Foundation
import CoreGraphics
import AppKit

public final class ScreenshotItem: Identifiable, ObservableObject {
    public let id: UUID
    public let cgImage: CGImage
    public let createdAt: Date
    public let displayID: CGDirectDisplayID
    
    @Published public var remainingSeconds: Int = 60
    @Published public var isHovered: Bool = false
    
    private var autoSaveTimer: Timer?
    private var onAutoSave: ((ScreenshotItem) -> Void)?
    
    public init(cgImage: CGImage, displayID: CGDirectDisplayID = CGMainDisplayID(), onAutoSave: ((ScreenshotItem) -> Void)? = nil) {
        self.id = UUID()
        self.cgImage = cgImage
        self.createdAt = Date()
        self.displayID = displayID
        self.onAutoSave = onAutoSave
        
        startTimer()
    }
    
    public var nsImage: NSImage {
        let size = NSSize(width: cgImage.width, height: cgImage.height)
        return NSImage(cgImage: cgImage, size: size)
    }
    
    public func startTimer() {
        stopTimer()
        let duration = AppPreferences.shared.previewDuration.rawValue
        remainingSeconds = duration
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 1 {
                self.remainingSeconds -= 1
            } else {
                self.remainingSeconds = 0
                self.stopTimer()
                self.onAutoSave?(self)
            }
        }
    }
    
    public func stopTimer() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    deinit {
        stopTimer()
    }
}
