import SwiftUI
import AppKit

public struct StackContainerView: View {
    @ObservedObject var appState: AppState
    
    // Smooth, gentle macOS native spring curve (subtle, refined, no jarring snap)
    private var stackSpringAnimation: Animation {
        .spring(response: 0.48, dampingFraction: 0.88, blendDuration: 0.15)
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main Cards Stack & Button Container (Always pinned to bottomTrailing)
            HStack(alignment: .bottom, spacing: 12) {
                // Stack Count & Chevron Toggle Button (Visible when count > 1)
                if appState.activeScreenshots.count > 1 {
                    Button(action: {
                        withAnimation(stackSpringAnimation) {
                            appState.toggleExpanded()
                        }
                    }) {
                        VStack(spacing: 3) {
                            Image(systemName: appState.isExpanded ? "chevron.down" : "chevron.up")
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
                    .help(appState.isExpanded ? "Collapse screenshot stack" : "Expand screenshot stack (\(appState.activeScreenshots.count))")
                    .padding(.bottom, 50)
                    .transition(.opacity.combined(with: .scale(scale: 0.85, anchor: .bottom)))
                    .zIndex(1000)
                }
                
                // Unified Cards Layer
                ZStack(alignment: .bottomTrailing) {
                    ForEach(Array(appState.activeScreenshots.enumerated()), id: \.element.id) { index, item in
                        let offsetIndex = (appState.activeScreenshots.count - 1) - index
                        let isTop = index == appState.activeScreenshots.count - 1
                        
                        // Vertical and Scale math:
                        // Collapsed: Top card is at 0, older cards peek subtly upward (-7px) directly behind
                        // Expanded: Cards glide smoothly into individual vertical slots (-162px each)
                        let targetYOffset: CGFloat = appState.isExpanded
                            ? CGFloat(offsetIndex) * -162.0
                            : CGFloat(offsetIndex) * -7.0
                        
                        let targetScale: CGFloat = appState.isExpanded
                            ? 1.0
                            : 1.0 - (CGFloat(offsetIndex) * 0.02)
                        
                        let targetOpacity: Double = appState.isExpanded
                            ? 1.0
                            : 1.0 - (Double(offsetIndex) * 0.06)
                        
                        MultiItemDragSource(items: {
                            appState.isExpanded ? [item] : appState.activeScreenshots
                        }) {
                            CornerCardView(
                                item: item,
                                isTopCard: isTop,
                                isExpanded: appState.isExpanded,
                                onCopy: { appState.copyScreenshot(item) },
                                onSave: { appState.saveScreenshot(item) },
                                onDelete: { appState.deleteScreenshot(item) },
                                onEdit: { appState.openEditor(for: item) }
                            )
                            .scaleEffect(targetScale, anchor: .bottom)
                            .opacity(targetOpacity)
                            .offset(x: 0, y: targetYOffset)
                            .zIndex(Double(index))
                            .animation(stackSpringAnimation, value: appState.isExpanded)
                        }
                    }
                }
                .frame(width: 220, height: 150, alignment: .bottomTrailing)
            }
            
            // Toast Overlay (e.g. "Saved to Desktop")
            if let toastMessage = appState.activeToastMessage {
                ToastBannerView(message: toastMessage)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 4)
                    .padding(.trailing, 4)
                    .zIndex(2000)
            }
            
            // Limit Reached Alert
            if appState.showLimitAlert {
                LimitAlertBannerView(onDismiss: { appState.showLimitAlert = false })
                    .transition(.scale.combined(with: .opacity))
                    .padding(.bottom, 4)
                    .padding(.trailing, 4)
                    .zIndex(2001)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
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
