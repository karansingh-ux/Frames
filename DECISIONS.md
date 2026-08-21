# Frames — Architectural & Product Decision Record (ADR)

This document tracks all product, architectural, and design decisions for **Frames**.  
**Rule:** Any conflicting requirement or ambiguity between source documents is marked **OPEN** until explicitly resolved by the product owner.

---

## Decision Log

### DEC-001: Screen Recording Scope
- **Decision:** Screen recording (video/audio) is excluded from Frames.
- **Reason:** Native macOS screen recording (⇧⌘5) is already robust and performant. Adding screen recording would add significant complexity and bloat to what should be an ultra-lightweight utility.
- **Status:** **CONFIRMED**
- **Consequences:** Scope is locked to Full Screenshot, Area Screenshot, and Scrolling Screenshot.

---

### DEC-002: Zero Screenshot History & Cloud Storage
- **Decision:** Frames will have zero persistent screenshot history, no local database (CoreData/SQLite), no cloud sync, and no user accounts.
- **Reason:** Frames is an ephemeral workflow accelerator, not a digital asset manager. Avoiding disk/cloud storage guarantees maximum user privacy and eliminates storage overhead.
- **Status:** **CONFIRMED**
- **Consequences:** Screenshots live purely in-memory (and temporary cache) during their active lifecycle. Once dismissed, copied, or deleted, memory is freed immediately.

---

### DEC-003: 5-Screenshot Active Cap & Limit Exceeded Behavior
- **Decision:** Exactly 5 maximum active screenshots can exist simultaneously in the corner stack.
- **Reason:** Prevents UI clutter and bounded memory usage (~200MB max uncompressed bitmap RAM).
- **Status:** **CONFIRMED**
- **Consequences:** When a 6th capture is attempted while 5 slots are full, capture is blocked and a non-intrusive alert is displayed: *"5 screenshots active. Save, copy, or remove one to continue."* Nothing is silently discarded.

---

### DEC-004: 60-Second Auto-Save Lifecycle & Fallback
- **Decision:** Un-actioned corner preview cards persist for 60 seconds. If no action is taken at $t = 60\text{s}$, the image is automatically saved to `~/Desktop` and the card is dismissed.
- **Reason:** Combines the safety of the native macOS auto-save behavior with the convenience of an extended staging window.
- **Status:** **CONFIRMED**
- **Consequences:** Explicit user actions (Copy, Save, Delete) immediately cancel the 60-second timer to avoid duplicate desktop saves or resurrection of deleted screenshots.

---

### DEC-005: Copy vs. Save Behavioral Invariants
- **Decision:**
  - **Copy:** Copies image data to `NSPasteboard` *only*. Zero files written to disk. Dismisses card.
  - **Save:** Writes image file to `~/Desktop` with macOS naming (`Screenshot YYYY-MM-DD at h.mm.ss a.png`). Shows brief confirmation toast and dismisses.
  - **Cancel / Delete (X):** Discards in-memory image and dismisses. Zero files written to disk.
- **Reason:** Eliminates desktop clutter for users who only want to paste an image into Slack/Mail/Figma.
- **Status:** **CONFIRMED**
- **Consequences:** Clean separation between clipboard buffer and file system.

---

### DEC-006: Self-Capture Window Exclusion
- **Decision:** Frames' overlay windows (corner cards, stack overlays, selection crosshairs) MUST be excluded from all screen captures.
- **Reason:** If taking screenshot #2 while card #1 is on screen, card #1 must not be baked into screenshot #2.
- **Status:** **CONFIRMED**
- **Consequences:** The capture pipeline must filter out Frames' own `CGWindowID`s using `SCContentFilter`.

---

### DEC-007: Scrolling Screenshot Modality & Slot Isolation
- **Decision:** Scrolling screenshots do not enter the corner card stack and do not consume one of the 5 active stack slots. They open directly in an expanded modal viewer.
- **Reason:** Long vertical screenshots are too large to preview legibly in a small corner thumbnail and require immediate detailed inspection or cropping.
- **Status:** **CONFIRMED**
- **Consequences:** The scrolling capture pipeline has a separate result presentation controller.

---

### DEC-008: Multi-Display Placement
- **Decision:** The floating preview card/stack appears on the specific display where the screenshot was taken.
- **Reason:** Aligns with native macOS behavior and user spatial expectations on multi-monitor setups.
- **Status:** **CONFIRMED**
- **Consequences:** Overlay window positioning logic must resolve display geometry dynamically.

---

### DEC-009: Default Global Hotkey Bindings
- **Decision:** Default Full Screen to `⌥⇧3`, Area to `⌥⇧4`, Scrolling to `⌥⇧5`.
- **Reason:** Provides familiar mnemonic matching native macOS (`3`, `4`, `5`) while using Option (`⌥`) to avoid conflicting with built-in macOS shortcuts on first launch, while permitting full remapping in Settings.
- **Status:** **CONFIRMED**
- **Consequences:** Safe, non-colliding default state on first launch.

---

### DEC-010: Minimum macOS Version & API Baseline
- **Decision:** Set minimum deployment target to macOS 14.0 (Sonoma) for first-class `ScreenCaptureKit` (`SCScreenshotManager`) and `SMAppService` APIs.
- **Reason:** Maximizes capture performance (hardware Metal acceleration) and reliability on modern macOS while maintaining support across 2018+ hardware.
- **Status:** **CONFIRMED**
- **Consequences:** Clean Swift 5.9/6 concurrency and deprecation-free native macOS APIs.

---

### DEC-011: Annotation Toolset Scope in V1
- **Decision:** Strictly 5 tools (Arrow, Text, Highlight, Blur, Crop).
- **Reason:** Maintains minimal, fast utility feel without becoming a bloated image editor.
- **Status:** **CONFIRMED**
- **Consequences:** Focused V1 scope achieved within time budget.

---

### DEC-012: Code Signing & Website Distribution Strategy
- **Decision:** Built release bundle with ad-hoc signing (`codesign --force --deep --sign - build/Frames.app`) and configured build pipeline for Developer ID Application signing and `notarytool` submission when active credentials are provided.
- **Reason:** Ready for local testing immediately, ready for direct distribution upon certificate attachment.
- **Status:** **CONFIRMED**
- **Consequences:** Standalone `.app` bundle generated at `build/Frames.app`.

---

## Phased Build Plan Summary

```
Phase 1: Project Shell & Permissions (Menu bar LSUIElement, permission flow, launch at login)
   │
Phase 2: Full Screenshot + Corner Card (SCKit engine, self-exclusion, 60s timer, copy/save)
   │
Phase 3: Area Screenshot + Stacking (Marquee selection, 5-card stack, hover fan-out, drag-and-drop)
   │
Phase 4: Scrolling Screenshot (Auto-scroll injection, frame stitching, onboarding guide, expanded modal)
   │
Phase 5: Settings, Hotkeys & Polish (Settings UI, hotkey conflict checks, HIG styling, signing setup)
```
