import SwiftUI
import AppKit

public struct StackContainerView: View {
    @ObservedObject var appState: AppState
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if appState.isExpanded && appState.activeScreenshots.count > 1 {
                // Expanded View: Vertical upward arrangement of individual floating cards with 12px gaps
                HStack(alignment: .bottom, spacing: 12) {
                    // Arrow Button on the Left of the bottom card
                    Button(action: {
                        appState.toggleExpanded()
                    }) {
                        VStack(spacing: 3) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(appState.activeScreenshots.count)")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .frame(width: 28, height: 44)
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
                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .help("Collapse screenshot stack")
                    .padding(.bottom, 50)
                    .zIndex(999)
                    
                    // Vertical stack of cards (Screenshot 5 at top down to Screenshot 1 at bottom)
                    VStack(spacing: 12) {
                        ForEach(appState.activeScreenshots.reversed()) { item in
                            MultiItemDragSource(items: { [item] }) {
                                CornerCardView(
                                    item: item,
                                    isTopCard: true,
                                    isExpanded: true,
                                    onCopy: { appState.copyScreenshot(item) },
                                    onSave: { appState.saveScreenshot(item) },
                                    onDelete: { appState.deleteScreenshot(item) },
                                    onEdit: { appState.openEditor(for: item) }
                                )
                            }
                        }
                    }
                }
                .transition(.opacity)
            } else if appState.activeScreenshots.count > 1 {
                // Collapsed Stack View: Multiple cards overlapping by 8px with arrow button clearly visible on left
                let maxShift = CGFloat(appState.activeScreenshots.count - 1) * 8.0
                
                HStack(alignment: .bottom, spacing: 12) {
                    // Arrow Button on Left (never covered by any card)
                    Button(action: {
                        appState.toggleExpanded()
                    }) {
                        VStack(spacing: 3) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(appState.activeScreenshots.count)")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .frame(width: 28, height: 44)
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
                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .help("Expand screenshot stack (\(appState.activeScreenshots.count))")
                    .padding(.bottom, 50)
                    .zIndex(999)
                    
                    // Cascaded Cards Container with native multi-item drag support
                    MultiItemDragSource(items: { appState.activeScreenshots }) {
                        ZStack(alignment: .bottomTrailing) {
                            ForEach(Array(appState.activeScreenshots.enumerated()), id: \.element.id) { index, item in
                                let offsetIndex = (appState.activeScreenshots.count - 1) - index
                                let xOffset = CGFloat(offsetIndex) * -8.0
                                let yOffset = CGFloat(offsetIndex) * -8.0
                                
                                CornerCardView(
                                    item: item,
                                    isTopCard: index == appState.activeScreenshots.count - 1,
                                    isExpanded: false,
                                    onCopy: { appState.copyScreenshot(item) },
                                    onSave: { appState.saveScreenshot(item) },
                                    onDelete: { appState.deleteScreenshot(item) },
                                    onEdit: { appState.openEditor(for: item) }
                                )
                                .offset(x: xOffset, y: yOffset)
                                .zIndex(Double(index))
                            }
                        }
                        .frame(width: 220 + maxShift, height: 150 + maxShift, alignment: .bottomTrailing)
                    }
                }
                .transition(.opacity)
            } else if let singleItem = appState.activeScreenshots.first {
                // Exactly One Screenshot Card with native drag support
                MultiItemDragSource(items: { [singleItem] }) {
                    CornerCardView(
                        item: singleItem,
                        isTopCard: true,
                        isExpanded: false,
                        onCopy: { appState.copyScreenshot(singleItem) },
                        onSave: { appState.saveScreenshot(singleItem) },
                        onDelete: { appState.deleteScreenshot(singleItem) },
                        onEdit: { appState.openEditor(for: singleItem) }
                    )
                }
                .transition(.opacity)
            }
            
            // Toast Overlay (e.g. "Saved to Desktop")
            if let toastMessage = appState.activeToastMessage {
                ToastBannerView(message: toastMessage)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 4)
                    .padding(.trailing, 4)
                    .zIndex(1000)
            }
            
            // Limit Reached Alert
            if appState.showLimitAlert {
                LimitAlertBannerView(onDismiss: { appState.showLimitAlert = false })
                    .transition(.scale.combined(with: .opacity))
                    .padding(.bottom, 4)
                    .padding(.trailing, 4)
                    .zIndex(1001)
            }
        }
        .padding(20)
        .animation(.easeInOut(duration: 0.2), value: appState.isExpanded)
        .animation(.easeInOut(duration: 0.2), value: appState.activeScreenshots.count)
    }
}

public struct ToastBannerView: View {
    let message: String
    
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 13, weight: .semibold))
            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.85))
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
        )
    }
}

public struct LimitAlertBannerView: View {
    var onDismiss: () -> Void
    
    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 14))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("5 screenshots active")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Text("Save, copy, or remove one to continue.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.85))
            }
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.9))
                .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
        )
    }
}
