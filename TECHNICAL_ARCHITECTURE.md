# Frames — Technical Architecture & Implementation Specification

> **Document Status:** TECHNICAL ARCHITECTURE  
> **Target Audience:** Engineering & AI Coding Agents  
> **Platform Target:** macOS (Universal 2: `x86_64` Intel + `arm64` Apple Silicon)

---

## 1. Executive Summary & Technology Stack

| Layer | Technology Choice | Rationale |
|---|---|---|
| **Language** | Swift 5.9+ / Swift 6 | Memory safety, native async/await, modern concurrency |
| **UI Framework** | SwiftUI + AppKit Bridges | SwiftUI for rapid, modern HIG views; AppKit (`NSPanel`, `NSStatusBar`) for precise window-level control |
| **Screen Capture Engine** | `ScreenCaptureKit` (`SCShareableContent`, `SCScreenshotManager`) | High performance, hardware acceleration, native window exclusion |
| **Global Hotkeys** | Carbon `RegisterEventHotKey` / `CGEventTap` wrapper | Reliable background global shortcut interception without active focus |
| **Launch at Login** | `ServiceManagement` (`SMAppService.mainApp`) | Modern macOS 13+ standard, no helper bundle required |
| **Image Processing** | `CoreGraphics`, `CoreImage`, `ImageIO`, Apple `Vision` | Ephemeral in-memory image buffers, high-DPI Retina scaling, stitching |
| **App Lifecycle** | `LSUIElement = 1` (Agent / Menu Bar only) | Headless utility; no Dock icon unless an expanded modal is open |

---

## 2. Screen Capture Architecture

### 2.1 API Evaluation: `ScreenCaptureKit` vs Legacy `CGWindowListCreateImage`

```
┌─────────────────────────┬───────────────────────────────┬───────────────────────────────┐
│ Feature / API           │ ScreenCaptureKit (Modern)     │ CoreGraphics (Legacy)         │
├─────────────────────────┼───────────────────────────────┼───────────────────────────────┤
│ macOS Version Support   │ macOS 12.3+ (13.0+ full API)  │ macOS 10.14+                  │
│ Performance             │ Hardware-accelerated (Metal)  │ CPU fallback / slower capture │
│ Window Exclusion        │ Built-in `SCContentFilter`    │ Manual window ID filtering    │
│ Retina / Multi-Display  │ Native scale & display aware  │ Manual point-to-pixel math    │
│ Deprecation Risk        │ Current Apple standard        │ Soft-deprecated, slow in Seq  │
└─────────────────────────┴───────────────────────────────┴───────────────────────────────┘
```

**Architectural Decision:** Adopt `ScreenCaptureKit` (`SCScreenshotManager` / `SCStream`).
- For macOS 13.0+ Ventura & 14.0+ Sonoma, `SCScreenshotManager.captureImage(contentFilter:configuration:)` captures a single frame synchronously or asynchronously in under 15ms.

### 2.2 Self-Capture Window Exclusion (Critical Invariant)
To prevent Frames' own bottom-right cards from appearing in subsequent captures:
1. Every Frames window (`NSPanel` / overlay) registers its `CGWindowID`.
2. When building `SCContentFilter`:
   ```swift
   let shareableContent = try await SCShareableContent.current
   let framesWindowIDs = AppState.shared.activeOverlayWindowIDs
   let excludedWindows = shareableContent.windows.filter { framesWindowIDs.contains($0.windowID) }
   
   let filter = SCContentFilter(display: targetDisplay, excludingWindows: excludedWindows)
   ```
3. This guarantees that whether 1 or 5 cards are floating in the bottom-right corner, they are completely invisible to the capture engine.

---

## 3. UI Overlay & Window Architecture

### 3.1 Window Level & Panel Behavior
- **Window Type:** `NSPanel` subclass with `.nonactivatingPanel` style mask.
- **Window Level:** `NSWindow.Level.floating` (or `.statusBar` / `.popUpMenu` level) to float above standard application windows without stealing keyboard focus from the active app.
- **Collection Behavior:** `[.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]` to remain visible across macOS spaces and full-screen apps.
- **Hosting:** `NSHostingView(rootView: ScreenshotCardView(...))` with `clear` background and `.ultraThinMaterial` backdrop.

### 3.2 Multi-Display Awareness
- On capture trigger, resolve the active `NSScreen` (where the cursor or key window is located via `NSScreen.screens` and `NSEvent.mouseLocation`).
- Position the corner panel relative to the target screen's `visibleFrame` (bottom-right origin with 16pt margin).

---

## 4. Screenshot Lifecycle & In-Memory State Machine

```
      [ Capture Event ] ──────────► [ Memory Slot Assigned (1..5) ]
                                                │
                                                ├── Start Timer (t = 0..60s)
                                                ▼
                                    ┌───────────────────────┐
                                    │ Active Corner State   │
                                    └───────────────────────┘
                                                │
          ┌─────────────────┬───────────────────┼───────────────────┬─────────────────┐
          ▼                 ▼                   ▼                   ▼                 ▼
     [ Copy Cmd ]      [ Save Cmd ]        [ Delete Cmd ]      [ Edit Cmd ]     [ Timeout: 60s ]
          │                 │                   │                   │                 │
  NSPasteboard.put   FileManager.write   Deallocate buffer   Pause 60s timer    FileManager.write
  Deallocate buffer  Deallocate buffer   Deallocate buffer   Open Modal Viewer  Deallocate buffer
  Dismiss Panel      Toast & Dismiss     Dismiss Panel       (Save/Copy/Delete) Dismiss Panel
```

### 4.1 Invariants
- Maximum capacity: 5 slots (`[ScreenshotItem]` array, capped at 5).
- Each `ScreenshotItem` holds:
  - `id: UUID`
  - `image: CGImage / NSImage`
  - `timestamp: Date`
  - `timer: AnyCancellable?`
  - `status: .active | .editing | .saved | .copied | .discarded`
- **Memory Footprint:** A full 5K Retina capture is ~40MB uncompressed bitmap in RAM. Max 5 active captures = ~200MB maximum transient memory. Zero disk writes until explicitly saved or timed out.

---

## 5. Drag-and-Drop Architecture

To support dragging into any macOS application (Slack, Mail, Finder, Figma, Chrome):
- The preview card view implements `onDrag { ... }` / `NSDraggingSource`.
- Provide an `NSItemProvider` configured with:
  1. `UTType.png` data representation (in-memory `NSData`).
  2. File Promise / Temporary URL provider (writes a temporary `.png` file to `NSTemporaryDirectory()` on demand for apps that require a file URL rather than raw image data).
  3. Temporary drag files are tagged for immediate deletion once the drag session completes or the app exits.

---

## 6. Scrolling / Long Screenshot Engine

### 6.1 Mechanical Flow
1. **Target Selection:** User defines a viewport bounding box `CGRect` over the scrollable application.
2. **Scroll Injection:** Using `CGEventCreateScrollWheelEvent2` (or Accessibility API `AXUIElement` vertical scroll action), simulate smooth downward scroll ticks.
3. **Continuous Capture:** Capture viewport frames at ~15–30 FPS or per-step scroll increments using `ScreenCaptureKit`.
4. **Image Stitching (Vision / Cross-Correlation):**
   - Compare overlapping horizontal slices of consecutive frames.
   - Compute vertical displacement $\Delta y$ via phase correlation or template matching (`CoreImage` / Apple `Vision` translation registration).
   - Stitch unique vertical slices into a unified `CGContext` bitmap.
5. **Termination:** Stop when:
   - Configured maximum height / scroll length is reached.
   - $\Delta y = 0$ over consecutive frames (reached bottom of scrollable page).
   - User presses `ESC` to cancel or finish.
6. **Result Presentation:** Open composite bitmap in standalone `ExpandedScreenshotModalView` (independent of the 5-card corner stack).

---

## 7. Global Hotkeys & Conflict Detection

### 7.1 Hotkey Registration
- Use Carbon `RegisterEventHotKey` API or a robust Swift wrapper (e.g. `HotKey` package pattern) which interacts with the macOS Window Server directly without requiring accessibility privileges for simple shortcut listening.

### 7.2 Conflict Detection Architecture
- **System Shortcuts:** Read `~/Library/Preferences/com.apple.symbolichotkeys.plist` or inspect system bindings to detect collisions with built-in macOS shortcuts (e.g. Spotlight `⌘Space`, Mission Control `^↑`, standard screenshots `⇧⌘3`/`⇧⌘4`/`⇧⌘5`).
- **Internal Collisions:** Ensure Full, Area, and Scrolling shortcuts within Frames cannot overlap.
- **Third-Party App Limit:** Technical limitation: macOS sandboxing and security model prevents querying private hotkeys registered by arbitrary running processes. The UI will explicitly state that conflict checking covers macOS system shortcuts and Frames shortcuts.

---

## 8. Permissions & System Access

```
                  [ Attempt Screen Capture ]
                              │
               CGPreflightScreenCaptureAccess()
                              │
               ┌──────────────┴──────────────┐
             Granted                      Denied
               │                             │
        Proceed to Capture        Show Native Permission Dialog
                                             │
                                  ┌──────────┴──────────┐
                            User Grants              User Denies
                                  │                       │
                            Continue Capture       Display Help Banner
                                                   + Direct Deep Link to
                                                   System Settings
```

- **Deep Link URL:** `x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture`
- **Accessibility Check (if scrolling requires synthetic events):** `AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt: true] as CFDictionary)`

---

## 9. Distribution, Signing & Notarization

### 9.1 Build Pipeline for Direct Web Distribution
1. **Compilation:** Universal 2 binary (`x86_64` + `arm64`) with Release optimizations.
2. **Entitlements:** Hardened Runtime enabled (`ENABLE_HARDENED_RUNTIME = YES`).
3. **Codesign:**
   ```bash
   codesign --force --options runtime --deep --sign "Developer ID Application: YourName (TeamID)" Frames.app
   ```
4. **Packaging:** Create `.dmg` or `.zip`.
5. **Notarization:**
   ```bash
   xcrun notarytool submit Frames.dmg --keychain-profile "notary-profile" --wait
   ```
6. **Stapling:**
   ```bash
   xcrun stapler staple Frames.dmg
   ```

---

## 10. Status Classification

### Confirmed Architectural Decisions
- [x] Language: Swift 5.9+ / Swift 6, SwiftUI + AppKit.
- [x] Architecture: Universal 2 (Intel + Apple Silicon).
- [x] Lifecycle: `LSUIElement` Menu Bar application.
- [x] In-memory storage: Max 5 active slots, strictly 0 persistent database/history.
- [x] Self-capture exclusion via window ID filtering.
- [x] Launch at Login via `SMAppService.mainApp`.

### Recommended Architectural Decisions
- [x] Minimum OS Target: macOS 13.0 (Ventura) or 14.0+ (Sonoma) to ensure first-class `ScreenCaptureKit` and `SMAppService` reliability while supporting all 2018+ hardware.
- [x] Image Stitching Engine: Native Apple `Vision` translation feature matching.

### Open Technical Questions
- [ ] Confirmation of Apple Developer Account availability for Developer ID signing & Notarization (vs. handling unsigned Gatekeeper workarounds).
- [ ] User confirmation on default global hotkey combinations (`⇧⌘3` vs `⌥⇧3` etc.).
