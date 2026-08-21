import SwiftUI
import AppKit

public enum AnnotationTool: String, CaseIterable, Identifiable {
    case draw = "Draw"
    case arrow = "Arrow"
    case text = "Text"
    case highlight = "Highlight"
    case blur = "Blur"
    case crop = "Crop"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .draw: return "pencil.tip"
        case .arrow: return "arrow.up.right"
        case .text: return "textformat"
        case .highlight: return "highlighter"
        case .blur: return "eye.slash"
        case .crop: return "crop"
        }
    }
}

public struct AnnotationElement: Identifiable {
    public let id = UUID()
    public var tool: AnnotationTool
    public var start: CGPoint
    public var end: CGPoint
    public var points: [CGPoint] = []
    public var text: String = ""
    public var color: Color = .red
}

public struct AnnotationView: View {
    @ObservedObject var item: ScreenshotItem
    var onSaveAndDismiss: (CGImage) -> Void
    var onCancel: () -> Void
    
    @State private var currentTool: AnnotationTool = .draw
    @State private var elements: [AnnotationElement] = []
    @State private var currentElement: AnnotationElement?
    @State private var selectedColor: Color = .red
    
    public var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 12) {
                ForEach(AnnotationTool.allCases) { tool in
                    Button(action: { currentTool = tool }) {
                        VStack(spacing: 2) {
                            Image(systemName: tool.iconName)
                                .font(.system(size: 14, weight: currentTool == tool ? .bold : .regular))
                            Text(tool.rawValue)
                                .font(.system(size: 10))
                        }
                        .foregroundColor(currentTool == tool ? .white : .primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(currentTool == tool ? Color.accentColor : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Divider().frame(height: 24)
                
                // Color Picker for drawings
                HStack(spacing: 6) {
                    ForEach([Color.red, Color.yellow, Color.green, Color.blue, Color.white, Color.black], id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 16, height: 16)
                            .overlay(Circle().stroke(Color.primary.opacity(0.3), lineWidth: selectedColor == color ? 2 : 0))
                            .onTapGesture { selectedColor = color }
                    }
                }
                
                Spacer()
                
                // Cancel and Done Buttons
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                
                Button("Done") {
                    let rendered = renderAnnotatedImage()
                    onSaveAndDismiss(rendered)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Canvas View
            GeometryReader { geo in
                ZStack {
                    Image(nsImage: item.nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Render drawn annotation elements
                    Canvas { context, size in
                        for el in elements {
                            drawElement(el, in: &context)
                        }
                        if let curr = currentElement {
                            drawElement(curr, in: &context)
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { value in
                                if currentElement == nil {
                                    currentElement = AnnotationElement(
                                        tool: currentTool,
                                        start: value.startLocation,
                                        end: value.location,
                                        points: [value.startLocation, value.location],
                                        color: selectedColor
                                    )
                                } else {
                                    currentElement?.end = value.location
                                    currentElement?.points.append(value.location)
                                }
                            }
                            .onEnded { value in
                                if var el = currentElement {
                                    el.end = value.location
                                    el.points.append(value.location)
                                    elements.append(el)
                                    currentElement = nil
                                }
                            }
                    )
                }
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
    
    private func drawElement(_ element: AnnotationElement, in context: inout GraphicsContext) {
        switch element.tool {
        case .draw:
            if element.points.count > 1 {
                var path = Path()
                path.move(to: element.points[0])
                for pt in element.points.dropFirst() {
                    path.addLine(to: pt)
                }
                context.stroke(path, with: .color(element.color), style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
            } else {
                var path = Path()
                path.addEllipse(in: CGRect(x: element.start.x - 1.5, y: element.start.y - 1.5, width: 3, height: 3))
                context.fill(path, with: .color(element.color))
            }
            
        case .arrow:
            var path = Path()
            path.move(to: element.start)
            path.addLine(to: element.end)
            context.stroke(path, with: .color(element.color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            
            // Draw arrow head
            let angle = atan2(element.end.y - element.start.y, element.end.x - element.start.x)
            let headLen: CGFloat = 12
            let p1 = CGPoint(x: element.end.x - headLen * cos(angle - .pi / 6), y: element.end.y - headLen * sin(angle - .pi / 6))
            let p2 = CGPoint(x: element.end.x - headLen * cos(angle + .pi / 6), y: element.end.y - headLen * sin(angle + .pi / 6))
            var headPath = Path()
            headPath.move(to: element.end)
            headPath.addLine(to: p1)
            headPath.addLine(to: p2)
            headPath.closeSubpath()
            context.fill(headPath, with: .color(element.color))
            
        case .highlight:
            let rect = CGRect(
                x: min(element.start.x, element.end.x),
                y: min(element.start.y, element.end.y),
                width: abs(element.end.x - element.start.x),
                height: abs(element.end.y - element.start.y)
            )
            context.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(Color.yellow.opacity(0.35)))
            
        case .blur:
            let rect = CGRect(
                x: min(element.start.x, element.end.x),
                y: min(element.start.y, element.end.y),
                width: abs(element.end.x - element.start.x),
                height: abs(element.end.y - element.start.y)
            )
            context.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(Color.black.opacity(0.85)))
            
        case .text:
            let point = element.start
            context.draw(Text("Text").font(.system(size: 16, weight: .bold)).foregroundColor(element.color), at: point)
            
        case .crop:
            let rect = CGRect(
                x: min(element.start.x, element.end.x),
                y: min(element.start.y, element.end.y),
                width: abs(element.end.x - element.start.x),
                height: abs(element.end.y - element.start.y)
            )
            context.stroke(Path(rect), with: .color(.white), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
        }
    }
    
    private func renderAnnotatedImage() -> CGImage {
        guard !elements.isEmpty else { return item.cgImage }
        
        let width = item.cgImage.width
        let height = item.cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return item.cgImage
        }
        
        // Draw base image
        ctx.draw(item.cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Scale elements from canvas coordinates to bitmap resolution
        let scaleX = max(1.0, CGFloat(width) / 700.0)
        let scaleY = max(1.0, CGFloat(height) / 500.0)
        
        for el in elements {
            let p1 = CGPoint(x: el.start.x * scaleX, y: CGFloat(height) - (el.start.y * scaleY))
            let p2 = CGPoint(x: el.end.x * scaleX, y: CGFloat(height) - (el.end.y * scaleY))
            
            switch el.tool {
            case .draw:
                guard el.points.count > 1 else { continue }
                ctx.setStrokeColor(NSColor(el.color).cgColor)
                ctx.setLineWidth(4.0 * scaleX)
                ctx.setLineCap(.round)
                ctx.setLineJoin(.round)
                ctx.beginPath()
                let first = el.points[0]
                ctx.move(to: CGPoint(x: first.x * scaleX, y: CGFloat(height) - (first.y * scaleY)))
                for pt in el.points.dropFirst() {
                    ctx.addLine(to: CGPoint(x: pt.x * scaleX, y: CGFloat(height) - (pt.y * scaleY)))
                }
                ctx.strokePath()
                
            case .arrow:
                ctx.setStrokeColor(NSColor(el.color).cgColor)
                ctx.setLineWidth(4.0 * scaleX)
                ctx.setLineCap(.round)
                ctx.beginPath()
                ctx.move(to: p1)
                ctx.addLine(to: p2)
                ctx.strokePath()
                
            case .highlight:
                let rect = CGRect(
                    x: min(p1.x, p2.x),
                    y: min(p1.y, p2.y),
                    width: abs(p2.x - p1.x),
                    height: abs(p2.y - p1.y)
                )
                ctx.setFillColor(NSColor.yellow.withAlphaComponent(0.35).cgColor)
                ctx.fill(rect)
                
            case .blur:
                let rect = CGRect(
                    x: min(p1.x, p2.x),
                    y: min(p1.y, p2.y),
                    width: abs(p2.x - p1.x),
                    height: abs(p2.y - p1.y)
                )
                ctx.setFillColor(NSColor.black.withAlphaComponent(0.85).cgColor)
                ctx.fill(rect)
                
            default:
                break
            }
        }
        
        return ctx.makeImage() ?? item.cgImage
    }
}
