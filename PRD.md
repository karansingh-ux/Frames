# Frames — Canonical Product Requirements Document (PRD)

> **Document Status:** CANONICAL SPECIFICATION  
> **Version:** 1.0  
> **Source Documents Reconciled:** `Frames-Product-Brief (1).md` & `Frames — Final Product Brief & Execution Specification.md`

---

## 1. Product Overview & Problem Statement

### 1.1 The Core Problem
On macOS, the built-in screenshot workflow presents significant friction for frequent users (taking 25–30+ screenshots daily):
1. **Vanishing Preview:** The thumbnail preview disappears after 5–10 seconds.
2. **Immediate Desktop Clutter:** Files are dumped directly onto `~/Desktop` regardless of whether the user only needed a transient copy for pasting into Slack, Mail, or Figma.
3. **No Batching / Multi-Capture Flow:** Capturing multiple sequential screenshots creates multiple loose files immediately and offers no unified staging area.

### 1.2 The Solution
**Frames** is an ultra-minimal, native macOS utility designed to make screenshots temporarily accessible in an interactive floating corner card / stack for **60 seconds**. Users can copy to clipboard without touching the disk, drag into any app, save explicitly, or let the app safely auto-save to Desktop after 60 seconds of inactivity.

---

## 2. Product Goals & Non-Goals

### 2.1 Goals
- **Familiar & Native:** Look and feel like a first-party Apple utility adhering strictly to Apple's Human Interface Guidelines (HIG).
- **Zero Learning Curve:** Obvious controls (`Copy`, `Save`, `Edit`, `Cancel`), zero hidden gestures.
- **Fast & Lightweight:** Menu-bar-only footprint (`LSUIElement`), low memory usage, immediate hotkey responsiveness.
- **Local-First & Ephemeral:** Zero cloud accounts, zero analytics, zero persistent screenshot history.

### 2.2 Non-Goals
- **No Screenshot Library / History:** No persistent database or gallery.
- **No Cloud Sync / Accounts:** Local-only operation.
- **No Screen Recording:** Native macOS screen recording covers this need; video capture is explicitly out of scope.
- **No Bloated Image Editor:** No complex graphic design tools; minimal annotation only.
- **No Mac App Store Distribution (Initial):** Distributed via direct website download.

---

## 3. Core Features & Modalities

### 3.1 Full-Screen Screenshot
- **Trigger:** `⌘3` (Command + 3 by default, configurable in Settings).
- **Behavior:** Captures the full screen of the active display where the cursor/trigger occurred.
- **Exclusion:** Frames' own UI overlay windows are excluded from capture.
- **Output:** A floating preview card appears in the bottom-right corner of the screen (anchored 24px from the bottom and 24px from the right edge).
- **Lifecycle:** Starts a 60-second timer. If un-actioned, auto-saves to `~/Desktop` and dismisses.

### 3.2 Area (Multi-)Screenshot
- **Trigger:** `⌘4` (Command + 4 by default, configurable in Settings).
- **Behavior:** Dimmed overlay with interactive crosshair marquee selection. User drags to select an area.
- **Multi-Capture Stacking:** Supports up to **5 active screenshots** simultaneously without replacing each other.
- **Stacking Layout:** Collapsed by default with cascade offset (~8px). An interactive small arrow button on the left edge/center toggles expansion.
- **Floating Expanded View:** Clicking the arrow expands the cards directly over the screen with zero dark container box behind them.
- **Limit Enforcement:** Max 5 active screenshots. If a 6th capture is attempted while 5 slots are occupied, capture is blocked and a non-intrusive alert appears:
  > *"5 screenshots active. Save, copy, or remove one to continue."*
  Nothing is silently overwritten or discarded.

### 3.3 Scrolling / Long Screenshot
- **Trigger:** `⌘5` (Command + 5 by default, configurable in Settings).
- **Behavior:** User selects a rectangular viewport. Frames injects synthetic scroll events, captures frames, and stitches them into a continuous vertical image.
- **First-Time Guidance:** A single-time, dismissible onboarding popover explaining how scrolling capture works upon first invocation.
- **Result Handling:** Opens directly in a separate window (**Expanded Modal Viewer**), never as the bottom-right corner thumbnail. Does not consume a stack slot.

---

## 4. Screenshot Lifecycle & Action Invariants

```
               [ User Triggers Capture ]
                          │
              ┌───────────┴───────────┐
              ▼                       ▼
    [ Full / Area Mode ]      [ Scrolling Mode ]
              │                       │
              ▼                       ▼
     [ Corner Card / Stack ]   [ Expanded Modal Viewer ]
              │                       │
     ┌────────┴────────┬──────────────┴────────┬───────────────┐
     ▼                 ▼                       ▼               ▼
  [ Copy ]          [ Save ]              [ Delete / X ]    [ 60s Timeout ]
     │                 │                       │               │
Clipboard Only    Write ~/Desktop        Discard in-memory  Auto-save ~/Desktop
Dismiss Card      "Saved" Toast & Dismiss Dismiss Card      Dismiss Card
```

### 4.1 Actions Breakdown
| Action | Target / Mechanism | File System Impact | Card / UI State |
|---|---|---|---|
| **Copy** | System Clipboard (`NSPasteboard.general`) | **No file created** on disk | Card dismisses immediately |
| **Save** | `~/Desktop/Screenshot YYYY-MM-DD at h.mm.ss a.png` | Writes PNG file | Brief confirmation ("Saved to Desktop"), then dismisses |
| **Cancel / Delete (X)** | Discard in-memory bitmap / cache | **No file created** | Card dismisses immediately |
| **Edit / Annotate** | Opens larger Annotation Modal | Ephemeral until explicitly saved/copied | Pauses 60s timer during active editing |
| **Drag & Drop** | `NSItemProvider` / `NSDraggingSource` | Exposes standard image data / temp promise | Drag out to Slack, Mail, Figma, Finder, etc. |

### 4.2 Auto-Save Safety Invariant
- If a screenshot is explicitly saved, copied, or deleted before 60 seconds, its timer is invalidated.
- A screenshot will **never** be saved to Desktop twice (once manually and once on timer expiry).
- A deleted screenshot will **never** be written to disk.

---

## 5. UI / UX Specifications

### 5.1 Corner Card Layout
- **Dimensions:** Compact preview card, approximately matching macOS native thumbnail scale (~180–220px width, aspect-ratio preserved).
- **Placement:** Bottom-right corner of the target display with standard macOS screen padding (~16–20px margin).
- **Materials:** Native macOS translucent blur (`.ultraThinMaterial` / `NSVisualEffectView`).
- **Corner Radius:** Standard macOS squircle (~10–12px).
- **Controls Layout:**
  - **Top-Left:** Small Dismiss (X) icon button (discards screenshot).
  - **Top-Right:** Small Edit / Annotation icon button (opens annotation modal).
  - **Center:** Two prominent circular action buttons: **Copy** (SF Symbol `doc.on.doc`) and **Save** (SF Symbol `arrow.down.to.line` or `square.and.arrow.down`).
  - **Visual Distinction:** Copy and Save must have distinct visual weights/icons to prevent mis-clicks.

### 5.2 Stack & Hover Interaction
- When 2–5 cards exist, they stack with an ~8–10px top/left cascade offset.
- Underlying cards show partial edges with subtle drop shadows.
- On hover (`mouseEntered` on stack container), the stack smoothly expands/fans out into a vertical or horizontal row of distinct cards.
- Each card in the expanded stack maintains its independent action buttons and drag-and-drop capability.

### 5.3 Annotation / Edit Toolset
- Minimal V1 Scope:
  1. **Arrow** (directional pointer)
  2. **Text** (caption / label)
  3. **Highlight** (translucent colored box / marker)
  4. **Blur / Redact** (pixelate / blackout sensitive data)
  5. **Crop** (adjust bounding box)
- *Additional shapes (rectangles, circles, freehand) deferred to V1.1 to preserve lightweight scope.*

### 5.4 Settings Window
- **Scale:** Small, fixed-size window matching the compact scale of macOS "About This Mac" / system accessory utilities.
- **Section 1: Hotkeys:**
  - Full-Screen Shortcut
  - Area Shortcut
  - Scrolling Shortcut
  - Key recording field with clear validation and conflict alerts.
- **Section 2: General Settings:**
  - Launch at Login toggle (default: ON)
  - Scrolling capture length preset (Short / Medium / Long / Custom)
  - Default save destination (default: `~/Desktop`)

---

## 6. Hotkeys & Conflict Detection

### 6.1 Default Hotkeys
- [UNRESOLVED / REQUIRES CLARIFICATION]:
  - macOS standard: ⇧⌘3 (Full Screen), ⇧⌘4 (Area/Selection), ⇧⌘5 (Capture Utility).
  - Doc 1 suggested ⇧⌘4 as default for Full Screenshot, which conflicts with standard macOS Area Screenshot.
  - **Proposed Standard Defaults:**
    - Full-Screen: `⇧⌘3` (or `⌥⇧3`)
    - Area Selection: `⇧⌘4` (or `⌥⇧4`)
    - Scrolling Capture: `⌥⇧5` (or `⇧⌘6`)

### 6.2 Conflict Detection Scope & Limits
- **Detectable:** System shortcuts registered in macOS default domain (`com.apple.symbolichotkeys.plist`) and internal Frames hotkey collisions.
- **Undetectable:** Private global hotkeys registered by third-party background applications via Carbon/CGEvent taps without system registration.
- **UX on Conflict:** Display clear alert banner: *"This shortcut is in use by macOS or Frames. Please choose another combination."* Suggest alternative if available.

---

## 7. Permissions & System Integration

### 7.1 Screen Recording Permission (`CGRequestScreenCaptureAccess` / `ScreenCaptureKit`)
- Requested on first capture attempt.
- Clean native modal explaining why permission is required ("Frames requires Screen Recording permission to capture screen contents").
- If denied or revoked: Show clear alert with direct button: `Open System Settings → Privacy & Security → Screen Recording`.

### 7.2 Accessibility Permission (`AXUIElement` / `CGEvent`)
- Required *only* if the scrolling capture engine requires synthetic scroll wheel event injection into target application viewports.
- Requested only when the user first triggers Scrolling Capture.

---

## 8. Distribution, Code Signing & Gatekeeper

- **Distribution Channel:** Direct `.dmg` / `.zip` download from the official Frames website.
- **Packaging Requirements:**
  - Hardened Runtime enabled.
  - Signed with Developer ID Application Certificate.
  - Notarized via Apple `notarytool` (`xcrun notarytool submit`).
  - Stapled ticket (`xcrun stapler staple`).
- **Unsigned Distribution Fallback [UNRESOLVED / USER DECISION]:** If published without a $99/yr Developer ID, users on macOS 13+ (and especially macOS 15 Sequoia) will encounter aggressive Gatekeeper blockages requiring manual Right-Click → Open or `xattr -cr` in Terminal.

---

## 9. Open Decisions & Reconciled Items

| Item | Source 1 | Source 2 | Reconciled Status / Recommendation |
|---|---|---|---|
| **Default Hotkey Mapping** | Listed ⇧⌘4 for Full Screen | General familiar defaults | **OPEN:** Recommend ⇧⌘3 for Full, ⇧⌘4 for Area, ⌥⇧5 for Scrolling. |
| **Minimum macOS Version** | macOS 10.14+ Mojave (2018 Macs) | Hardware 2018+, OS based on APIs | **OPEN / RECOMMENDED:** macOS 13.0+ (Ventura) to support `ScreenCaptureKit` & `SMAppService`. (2018 Macs support macOS 13+). |
| **Annotation Tools Scope** | 5 tools (Arrow, Text, Highlight, Blur, Crop) | 7 tools listed as potential | **CONFIRMED:** Keep strictly to the 5 minimal tools for V1. |
| **Multi-Display Placement** | Display where capture occurred | Unspecified | **CONFIRMED:** Corner card appears on the display where the capture was triggered. |
| **Code Signing Plan** | Notes $99/yr requirement | Notes Developer ID & Notarization | **OPEN:** Awaiting confirmation of Developer ID availability vs unsigned release. |
