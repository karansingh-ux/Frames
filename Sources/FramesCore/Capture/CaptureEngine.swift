import Foundation
import CoreGraphics
import ScreenCaptureKit
import AppKit

public final class CaptureEngine {
    public static let shared = CaptureEngine()
    
    private init() {}
    
    public func captureFullScreen(displayID: CGDirectDisplayID = CGMainDisplayID(), excludedWindowIDs: [CGWindowID] = []) async throws -> CGImage {
        let shareable = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let display = shareable.displays.first(where: { $0.displayID == displayID }) ?? shareable.displays.first else {
            throw CaptureError.displayNotFound
        }
        
        let excludedWindows = shareable.windows.filter { excludedWindowIDs.contains(CGWindowID($0.windowID)) }
        let filter = SCContentFilter(display: display, excludingWindows: excludedWindows)
        
        let config = SCStreamConfiguration()
        config.width = Int(display.width)
        config.height = Int(display.height)
        config.showsCursor = false
        config.scalesToFit = false
        
        return try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
    }
    
    public func captureRect(_ rect: CGRect, displayID: CGDirectDisplayID = CGMainDisplayID(), excludedWindowIDs: [CGWindowID] = []) async throws -> CGImage {
        let fullImage = try await captureFullScreen(displayID: displayID, excludedWindowIDs: excludedWindowIDs)
        
        // Convert screen coordinates to image bitmap coordinates (handling Retina / scaling)
        guard let screen = NSScreen.screens.first(where: {
            guard let idNum = $0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return false }
            return idNum.uint32Value == displayID
        }) ?? NSScreen.main else {
            throw CaptureError.displayNotFound
        }
        
        let screenWidth = max(1.0, screen.frame.width)
        let screenHeight = max(1.0, screen.frame.height)
        let scaleX = CGFloat(fullImage.width) / screenWidth
        let scaleY = CGFloat(fullImage.height) / screenHeight
        
        // AppKit has (0,0) at bottom-left, CGImage has (0,0) at top-left
        let normalizedX = max(0, rect.origin.x - screen.frame.origin.x)
        let normalizedY = max(0, rect.origin.y - screen.frame.origin.y)
        let flippedY = max(0, screenHeight - normalizedY - rect.height)
        
        let cropRect = CGRect(
            x: normalizedX * scaleX,
            y: flippedY * scaleY,
            width: min(CGFloat(fullImage.width) - (normalizedX * scaleX), rect.width * scaleX),
            height: min(CGFloat(fullImage.height) - (flippedY * scaleY), rect.height * scaleY)
        )
        
        guard let cropped = fullImage.cropping(to: cropRect) else {
            throw CaptureError.cropFailed
        }
        
        return cropped
    }
}

public enum CaptureError: LocalizedError {
    case displayNotFound
    case captureFailed
    case cropFailed
    case permissionDenied
    
    public var errorDescription: String? {
        switch self {
        case .displayNotFound: return "Target display could not be found."
        case .captureFailed: return "Failed to capture screen image."
        case .cropFailed: return "Failed to crop selected area."
        case .permissionDenied: return "Screen Recording permission is required to capture screenshots."
        }
    }
}
