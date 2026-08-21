# Frames — Mandatory Development Rules & Engineering Guardrails

These rules are permanent guardrails for all AI coding agents, subagents, and human contributors working on the **Frames** codebase. Every coding session must adhere to these constraints without exception.

---

## 1. Product Scope & Integrity Rules
1. **Never Invent Features:** If a feature, setting, button, or menu item is not explicitly documented in [`PRD.md`](./PRD.md), **do not build it**.
2. **Never Change Product Requirements Without Approval:** If an architectural change impacts product behavior, stop and request user confirmation first.
3. **No Screenshot History or Library:** Frames must never store a permanent log, database (SQLite, CoreData, Realm), or gallery of past screenshots.
4. **No Cloud Storage or User Accounts:** All data remains strictly local and ephemeral on the user's Mac. No telemetry, analytics, or external network requests.
5. **No Screen Recording:** Video and audio recording are explicitly out of scope. Do not build screen recording pipelines.

---

## 2. Hard Invariants & Behavioral Constraints
1. **Max 5 Active Screenshots:**
   - The active corner stack must never exceed 5 slots.
   - If a 6th capture is attempted while 5 slots are full, display the non-intrusive limit warning:  
     *"5 screenshots active. Save, copy, or remove one to continue."*
   - Never auto-dismiss or silently overwrite an existing screenshot to make room for a new one.
2. **60-Second Staging Lifecycle:**
   - Preview cards stay active in the bottom-right corner for 60 seconds.
   - If un-actioned after 60 seconds, auto-save to `~/Desktop` and dismiss.
   - Explicit user actions (`Copy`, `Save`, `Delete`) immediately invalidate the 60s timer.
3. **Copy vs. Save Strict Separation:**
   - **Copy:** Writes image data to `NSPasteboard` *only*. Never writes to disk.
   - **Save:** Writes image file directly to `~/Desktop` with macOS timestamp naming convention (`Screenshot YYYY-MM-DD at h.mm.ss a.png`).
   - **Cancel / Delete (X):** Destroys in-memory data immediately. Saves nothing.
4. **Self-Capture Exclusion:**
   - Frames' own UI elements (preview cards, stack overlays, selection crosshairs) must be excluded from all screen captures using `SCContentFilter` / window list filtering.
5. **Scrolling Capture Slot Exemption:**
   - Scrolling screenshots open directly in the Expanded Modal Viewer and do not enter the 5-slot corner stack.

---

## 3. Technology & Architecture Standards
1. **Native macOS First:**
   - Use Swift 5.9+ / Swift 6 and SwiftUI paired with AppKit (`NSPanel`, `NSStatusBar`, `NSPasteboard`, `NSDraggingSource`).
   - Strictly **NO web wrappers, NO Electron, NO React Native**.
2. **No Unjustified Third-Party Dependencies:**
   - Prefer first-party Apple frameworks (`ScreenCaptureKit`, `CoreGraphics`, `Vision`, `ServiceManagement`, `UniformTypeIdentifiers`).
   - Third-party packages (e.g. lightweight global hotkey helpers) must be strictly justified and approved.
3. **Performance & Memory Hygiene:**
   - Bitmap buffers must be deallocated as soon as an item is dismissed, saved, or copied.
   - Total active memory footprint must remain minimal (<250MB under maximum 5-card load).
4. **Do Not Rewrite Working Code:**
   - Refactor only when fixing bugs or integrating new phases. Preserve existing, tested components.

---

## 4. Ambiguity Resolution Protocol
When encountering ambiguous requirements, contradictory instructions, or unspecified edge cases:
1. **State the Ambiguity:** Clearly describe what is unclear.
2. **Explain the Impact:** Detail the technical or UX ramifications of different choices.
3. **Provide Recommended Default:** Give your recommended approach based on Apple HIG and the Frames philosophy.
4. **Ask Before Proceeding:** Stop and wait for product owner confirmation before implementing if product behavior is affected.

---

## 5. Verification & Testing Guardrails
1. **Test After Every Significant Change:** Verify build compilation, window placement, memory deallocation, and permission states before marking a phase complete.
2. **Never Mock Core Capabilities:** Always implement against real macOS APIs (`ScreenCaptureKit`, `NSPasteboard`, `CGEvent`).
