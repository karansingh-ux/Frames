import Foundation
import AppKit
import CoreGraphics

public final class DesktopSaver {
    public static let shared = DesktopSaver()
    
    private init() {}
    
    public func formattedDateString(from date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd 'at' h.mm.ss a"
        return formatter.string(from: date)
    }
    
    public func generateScreenshotFilename(for date: Date = Date(), extension ext: String = "png") -> String {
        let dateString = formattedDateString(from: date)
        return "Screenshot \(dateString).\(ext)"
    }
    
    public func saveImageToDisk(_ cgImage: CGImage, inDirectory directoryPath: String? = nil) -> URL? {
        let targetDirectory = directoryPath ?? AppPreferences.shared.saveDirectoryPath
        let folderURL = URL(fileURLWithPath: targetDirectory)
        
        // Ensure folder exists
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        
        // Determine format
        let format = AppPreferences.shared.saveFormat
        let (fileExtension, fileType, fileProperties): (String, NSBitmapImageRep.FileType, [NSBitmapImageRep.PropertyKey: Any]) = {
            switch format {
            case .png:
                return ("png", .png, [:])
            case .jpeg:
                return ("jpg", .jpeg, [.compressionFactor: 0.92])
            case .auto:
                // If image has alpha or transparency, use PNG; otherwise if opaque, use JPEG
                let alphaInfo = cgImage.alphaInfo
                let hasAlpha = alphaInfo == .first || alphaInfo == .last || alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast
                if hasAlpha {
                    return ("png", .png, [:])
                } else {
                    return ("jpg", .jpeg, [.compressionFactor: 0.92])
                }
            }
        }()
        
        let baseFilename = generateScreenshotFilename(extension: fileExtension)
        var destinationURL = folderURL.appendingPathComponent(baseFilename)
        
        // Handle name collision
        var counter = 1
        let nameWithoutExt = destinationURL.deletingPathExtension().lastPathComponent
        while FileManager.default.fileExists(atPath: destinationURL.path) {
            let uniqueName = "\(nameWithoutExt) (\(counter)).\(fileExtension)"
            destinationURL = folderURL.appendingPathComponent(uniqueName)
            counter += 1
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let data = bitmapRep.representation(using: fileType, properties: fileProperties) else {
            return nil
        }
        
        do {
            try data.write(to: destinationURL, options: .atomic)
            return destinationURL
        } catch {
            NSLog("[Frames] Error saving screenshot to disk: \(error.localizedDescription)")
            return nil
        }
    }
}
