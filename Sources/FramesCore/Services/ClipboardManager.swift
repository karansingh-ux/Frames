import Foundation
import AppKit
import CoreGraphics

public final class ClipboardManager {
    public static let shared = ClipboardManager()
    
    private init() {}
    
    @discardableResult
    public func copyImageToClipboard(_ cgImage: CGImage) -> Bool {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            return false
        }
        
        pasteboard.declareTypes([.png, .tiff], owner: nil)
        pasteboard.setData(pngData, forType: .png)
        
        if let tiffData = bitmapRep.tiffRepresentation {
            pasteboard.setData(tiffData, forType: .tiff)
        }
        
        return true
    }
}
