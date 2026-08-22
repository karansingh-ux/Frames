import Foundation
import AppKit
import UniformTypeIdentifiers
import CoreGraphics

public final class ScreenshotDragItem: NSObject, NSPasteboardWriting {
    public let fileURL: URL
    public let pngData: Data
    public let tiffData: Data?
    
    public init(fileURL: URL, pngData: Data, tiffData: Data?) {
        self.fileURL = fileURL
        self.pngData = pngData
        self.tiffData = tiffData
        super.init()
    }
    
    public func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [
            .fileURL,
            NSPasteboard.PasteboardType(UTType.fileURL.identifier),
            NSPasteboard.PasteboardType(UTType.png.identifier),
            NSPasteboard.PasteboardType("Apple PNG pasteboard type"),
            .tiff
        ]
    }
    
    public func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        if type == .fileURL || type.rawValue == UTType.fileURL.identifier {
            return (fileURL as NSURL).pasteboardPropertyList(forType: .fileURL)
        } else if type.rawValue == UTType.png.identifier || type.rawValue == "Apple PNG pasteboard type" {
            return pngData
        } else if type == .tiff {
            return tiffData
        }
        return nil
    }
}

public final class DragDropManager {
    public static let shared = DragDropManager()
    
    private let cacheDirectory: URL
    
    private init() {
        let tempDir = FileManager.default.temporaryDirectory
        self.cacheDirectory = tempDir.appendingPathComponent("FramesDragCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        cleanCache()
    }
    
    public func prepareDragItems(for items: [ScreenshotItem]) -> [ScreenshotDragItem] {
        var dragItems: [ScreenshotDragItem] = []
        for (index, item) in items.enumerated() {
            let suffix = items.count > 1 ? " (\(index + 1))" : ""
            let filename = "Screenshot \(DesktopSaver.shared.formattedDateString(from: item.createdAt))\(suffix).png"
            let fileURL = cacheDirectory.appendingPathComponent(filename)
            
            let bitmapRep = NSBitmapImageRep(cgImage: item.cgImage)
            let pngData = bitmapRep.representation(using: .png, properties: [:]) ?? Data()
            let tiffData = bitmapRep.representation(using: .tiff, properties: [:])
            
            try? pngData.write(to: fileURL, options: .atomic)
            
            let writer = ScreenshotDragItem(fileURL: fileURL, pngData: pngData, tiffData: tiffData)
            dragItems.append(writer)
        }
        return dragItems
    }
    
    public func prepareCacheFiles(for items: [ScreenshotItem]) -> [URL] {
        return prepareDragItems(for: items).map { $0.fileURL }
    }
    
    public func prepareCacheFile(for cgImage: CGImage, suggestedName: String? = nil) -> URL {
        let filename = suggestedName ?? "Screenshot \(DesktopSaver.shared.formattedDateString()).png"
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        if let data = bitmapRep.representation(using: .png, properties: [:]) {
            try? data.write(to: fileURL, options: .atomic)
        }
        return fileURL
    }
    
    public func createItemProvider(for cgImage: CGImage, suggestedName: String? = nil) -> NSItemProvider {
        let fileURL = prepareCacheFile(for: cgImage, suggestedName: suggestedName)
        let provider = NSItemProvider(contentsOf: fileURL) ?? NSItemProvider()
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        if let pngData = bitmapRep.representation(using: .png, properties: [:]) {
            provider.registerDataRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) { completion in
                completion(pngData, nil)
                return nil
            }
        }
        
        let size = NSSize(width: cgImage.width, height: cgImage.height)
        let nsImage = NSImage(cgImage: cgImage, size: size)
        provider.registerObject(nsImage, visibility: .all)
        
        return provider
    }
    
    public func createDragPreview(for cgImage: CGImage, totalCount: Int, index: Int) -> NSImage {
        let targetSize = NSSize(width: 220, height: 150)
        let canvas = NSImage(size: targetSize)
        
        canvas.lockFocus()
        
        let imageRect = NSRect(origin: .zero, size: targetSize)
        let path = NSBezierPath(roundedRect: imageRect, xRadius: 10, yRadius: 10)
        path.addClip()
        
        let rep = NSBitmapImageRep(cgImage: cgImage)
        rep.draw(in: imageRect)
        
        // If multiple items are being dragged and this is the top card, draw the count badge
        if totalCount > 1 && index == totalCount - 1 {
            let badgeText = "\(totalCount) Images"
            let font = NSFont.systemFont(ofSize: 12, weight: .bold)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor.white
            ]
            let attrString = NSAttributedString(string: badgeText, attributes: attributes)
            let textSize = attrString.size()
            
            let badgeWidth = textSize.width + 18
            let badgeHeight: CGFloat = 26
            let badgeRect = NSRect(
                x: targetSize.width - badgeWidth - 10,
                y: targetSize.height - badgeHeight - 10,
                width: badgeWidth,
                height: badgeHeight
            )
            
            let badgePath = NSBezierPath(roundedRect: badgeRect, xRadius: 13, yRadius: 13)
            NSColor(red: 0.05, green: 0.45, blue: 0.95, alpha: 0.95).setFill()
            badgePath.fill()
            
            NSColor.white.withAlphaComponent(0.5).setStroke()
            badgePath.lineWidth = 1.0
            badgePath.stroke()
            
            let textPoint = NSPoint(
                x: badgeRect.origin.x + (badgeWidth - textSize.width) / 2.0,
                y: badgeRect.origin.y + (badgeHeight - textSize.height) / 2.0
            )
            attrString.draw(at: textPoint)
        }
        
        canvas.unlockFocus()
        return canvas
    }
    
    public func removeCache(for item: ScreenshotItem) {
        let dateStr = DesktopSaver.shared.formattedDateString(from: item.createdAt)
        guard let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else { return }
        for file in files {
            if file.lastPathComponent.contains(dateStr) {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
    
    public func purgeAllCache() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else { return }
        for file in files {
            try? FileManager.default.removeItem(at: file)
        }
    }
    
    public func cleanCache() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey]) else { return }
        let now = Date()
        for file in files {
            if let attrs = try? file.resourceValues(forKeys: [.contentModificationDateKey]),
               let modDate = attrs.contentModificationDate,
               now.timeIntervalSince(modDate) > 600 { // 10 minutes old
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}
