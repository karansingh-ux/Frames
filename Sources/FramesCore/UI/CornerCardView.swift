import SwiftUI
import AppKit

public struct CornerCardView: View {
    @ObservedObject var item: ScreenshotItem
    var isTopCard: Bool = true
    var isExpanded: Bool = false
    
    var onCopy: () -> Void
    var onSave: () -> Void
    var onDelete: () -> Void
    var onEdit: () -> Void
    
    @State private var isHovering: Bool = false
    
    public var body: some View {
        ZStack {
            // 1. Preview Image
            Image(nsImage: item.nsImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 220, maxHeight: 150)
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            // 2. Translucent overlay controls (visible on top card, when expanded, or on hover)
            if isTopCard || isExpanded || isHovering {
                // Top controls bar
                VStack {
                    HStack {
                        // Cancel / Delete (X) button
                        Button(action: onDelete) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(Color.black.opacity(0.7)))
                        }
                        .buttonStyle(.plain)
                        .help("Delete screenshot (does not save)")
                        
                        Spacer()
                        
                        // Remaining seconds badge
                        Text("\(item.remainingSeconds)s")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.black.opacity(0.65)))
                        
                        Spacer()
                        
                        // Edit / Annotate button
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(Color.black.opacity(0.7)))
                        }
                        .buttonStyle(.plain)
                        .help("Annotate / Edit")
                    }
                    .padding(8)
                    
                    Spacer()
                }
                
                // Centered Side-by-Side Pill Action Buttons (Dead-Center Vertically and Horizontally)
                HStack(spacing: 5) {
                    // Copy Pill Button
                    Button(action: onCopy) {
                        HStack(spacing: 5) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 10, weight: .semibold))
                            Text("Copy")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.85))
                                .background(.ultraThinMaterial)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .help("Copy to clipboard (no file saved)")
                    
                    // Save Pill Button
                    Button(action: onSave) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.down.to.line")
                                .font(.system(size: 10, weight: .semibold))
                            Text("Save")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.accentColor.opacity(0.95))
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .help("Save to Desktop")
                }
            }
        }
        .frame(width: 220, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
