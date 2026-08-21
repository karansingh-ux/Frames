# Frames — Project Knowledge Base & AI Agent Context

## System & Project Identity
- **Project Name:** Frames
- **Tagline:** Lightweight, native macOS screenshot utility
- **Core Purpose:** Capture screenshots instantly, keep them immediately accessible in a temporary floating stack (up to 5), and eliminate desktop clutter without premature auto-saving.
- **Platform:** Native macOS (Intel `x86_64` + Apple Silicon `arm64` Universal 2 binary)
- **Target OS Range:** macOS 13.0 (Ventura) or 14.0+ recommended for modern `ScreenCaptureKit` and `SMAppService` APIs, supporting 2018+ Mac hardware. (See `DECISIONS.md` for compatibility baseline).
- **Language / Framework:** Swift 5.9+ / Swift 6, SwiftUI for UI overlays and Settings, AppKit (`NSPanel`, `NSStatusBar`, `NSPasteboard`, `NSDraggingSource`) for low-level system integration.
- **Distribution:** Direct download from website (outside Mac App Store), `LSUIElement` Menu-Bar App.

---

## Core Features & Modalities
1. **Full-Screen Screenshot:** Captures the full screen, creates temporary preview card in bottom-right corner.
2. **Area / Selection Screenshot:** Interactive marquee selection, produces temporary preview card; up to 5 cards stack with offset.
3. **Scrolling / Long Screenshot:** Auto-scrolls and stitches long content (webpages, documents, chat threads); opens directly in an expanded modal view (bypasses corner stack, doesn't consume 1 of the 5 stack slots).

---

## Hard Product Constraints (Never Violate)
1. **Zero History / Zero Library:** No database, no CoreData, no SQLite, no cloud sync, no server endpoints, no user accounts. All capture data is ephemeral in-memory (or temporary sandbox cache cleared on dismiss/save).
2. **Strict 5-Screenshot Active Cap:** Exactly 5 maximum active corner cards across Full/Area modes. 6th capture attempt triggers a non-intrusive blocking prompt ("5 screenshots active. Save, copy, or remove one to continue"). Never silently discard or auto-overwrite.
3. **60-Second Auto-Save Lifecycle:** Un-actioned corner preview cards persist for 60 seconds. At t = 60s, card auto-saves to `~/Desktop` and dismisses.
4. **Copy vs. Save Invariants:**
   - **Copy:** Writes image to `NSPasteboard` *only*. Never writes to disk. Dismisses card immediately.
   - **Save:** Writes image file to `~/Desktop` with macOS-standard naming (`Screenshot YYYY-MM-DD at h.mm.ss a.png`). Shows brief visual confirmation ("Saved to Desktop") and dismisses.
   - **Cancel / Delete (X):** Immediately destroys in-memory image and dismisses. Saves nothing.
5. **Self-Capture Window Exclusion:** Frames' own UI (corner cards, stack overlays, helper panels) MUST be excluded from all screen captures via `SCContentFilter` or window list filtering.
6. **No Screen Recording:** Video/audio screen recording is strictly out of scope (macOS native tool handles this).
7. **Apple HIG Compliance:** Native San Francisco font, standard macOS materials (`NSVisualEffectView` / `.ultraThinMaterial`), standard system symbols (SF Symbols), native drag-and-drop (`NSItemProvider` / `pasteboardWriter`).

---

## Standing Rules for Engineering Sessions
- **Do not invent features:** If a capability is not in `PRD.md`, do not add it.
- **Prefer native Apple APIs:** Avoid heavy third-party dependencies unless strictly justified (e.g., lightweight global hotkey management).
- **Ambiguity protocol:** If a requirement or edge case is ambiguous, identify the ambiguity, explain the behavioral impact, propose a recommended default, and ask the user before writing code.
- **Never mock or fake core system behavior:** Screen capture, global hotkeys, drag-and-drop, and permissions must be implemented against actual macOS system APIs.
- **Single Source of Truth:** Consult `PRD.md` for product specs and `DECISIONS.md` for architectural decision history.
