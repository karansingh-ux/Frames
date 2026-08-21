import Cocoa
import CoreGraphics

func generateIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()
    
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    // Canvas dimensions
    let rect = CGRect(x: 0, y: 0, width: s, height: s)
    
    // macOS Standard Squircle Path
    let inset: CGFloat = s * 0.10
    let iconRect = rect.insetBy(dx: inset, dy: inset)
    let cornerRadius: CGFloat = s * 0.22
    let squirclePath = CGPath(roundedRect: iconRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    ctx.saveGState()
    ctx.addPath(squirclePath)
    ctx.clip()
    
    // Gradient Background (Dark modern macOS graphite / dark navy)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        NSColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1.0).cgColor,
        NSColor(red: 0.06, green: 0.07, blue: 0.09, alpha: 1.0).cgColor
    ] as CFArray
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) {
        ctx.drawLinearGradient(gradient, start: CGPoint(x: s/2, y: iconRect.maxY), end: CGPoint(x: s/2, y: iconRect.minY), options: [])
    }
    
    // Subtle Inner Glow / Border
    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.18).cgColor)
    ctx.setLineWidth(max(1.0, s * 0.015))
    ctx.addPath(squirclePath)
    ctx.strokePath()
    
    ctx.restoreGState()
    
    // Outer Drop Shadow for the squircle
    // Now draw the 4-corner viewfinder frame logo in the center
    let centerRect = iconRect.insetBy(dx: iconRect.width * 0.22, dy: iconRect.height * 0.22)
    let lineWidth: CGFloat = max(2.0, s * 0.055)
    let cornerLen: CGFloat = centerRect.width * 0.28
    
    ctx.setStrokeColor(NSColor(red: 0.25, green: 0.65, blue: 1.0, alpha: 1.0).cgColor) // macOS vibrant cyan/blue accent
    ctx.setLineWidth(lineWidth)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    
    // Top-Left Corner
    let tl = CGMutablePath()
    tl.move(to: CGPoint(x: centerRect.minX, y: centerRect.maxY - cornerLen))
    tl.addLine(to: CGPoint(x: centerRect.minX, y: centerRect.maxY))
    tl.addLine(to: CGPoint(x: centerRect.minX + cornerLen, y: centerRect.maxY))
    ctx.addPath(tl)
    ctx.strokePath()
    
    // Top-Right Corner
    let tr = CGMutablePath()
    tr.move(to: CGPoint(x: centerRect.maxX - cornerLen, y: centerRect.maxY))
    tr.addLine(to: CGPoint(x: centerRect.maxX, y: centerRect.maxY))
    tr.addLine(to: CGPoint(x: centerRect.maxX, y: centerRect.maxY - cornerLen))
    ctx.addPath(tr)
    ctx.strokePath()
    
    // Bottom-Left Corner
    let bl = CGMutablePath()
    bl.move(to: CGPoint(x: centerRect.minX, y: centerRect.minY + cornerLen))
    bl.addLine(to: CGPoint(x: centerRect.minX, y: centerRect.minY))
    bl.addLine(to: CGPoint(x: centerRect.minX + cornerLen, y: centerRect.minY))
    ctx.addPath(bl)
    ctx.strokePath()
    
    // Bottom-Right Corner
    let br = CGMutablePath()
    br.move(to: CGPoint(x: centerRect.maxX - cornerLen, y: centerRect.minY))
    br.addLine(to: CGPoint(x: centerRect.maxX, y: centerRect.minY))
    br.addLine(to: CGPoint(x: centerRect.maxX, y: centerRect.minY + cornerLen))
    ctx.addPath(br)
    ctx.strokePath()
    
    // Small Center Focus Point
    let centerDotRadius: CGFloat = max(1.5, s * 0.02)
    ctx.setFillColor(NSColor.white.withAlphaComponent(0.85).cgColor)
    ctx.fillEllipse(in: CGRect(x: centerRect.midX - centerDotRadius, y: centerRect.midY - centerDotRadius, width: centerDotRadius * 2, height: centerDotRadius * 2))
    
    image.unlockFocus()
    return image
}

let iconsetDir = "Resources/AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

let sizes: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (name, size) in sizes {
    let img = generateIcon(size: size)
    if let tiff = img.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let png = rep.representation(using: .png, properties: [:]) {
        let path = "\(iconsetDir)/\(name)"
        try? png.write(to: URL(fileURLWithPath: path))
    }
}

print("Generated iconset successfully.")
