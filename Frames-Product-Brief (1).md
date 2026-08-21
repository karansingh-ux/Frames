# Frames — Product Brief

**Platform:** Native macOS app (Swift/SwiftUI recommended)
**Compatibility:** macOS versions released after 2018 (i.e. macOS Mojave and later)
**Distribution:** Outside the Mac App Store, via own website, free to download
**Dev approach:** No-code / AI-assisted tools (e.g. Claude Code, Codex, Google Antigravity) — brief is written to be turned directly into build prompts

---

## 1. The Problem

macOS's built-in screenshot tool (⇧⌘4) captures instantly, but the preview thumbnail disappears after 5–10 seconds and the file auto-saves to the Desktop. For anyone taking 25–30+ screenshots a day, this means:
- Constant interruption to switch apps and paste before the preview vanishes
- A Desktop cluttered with loose screenshot files
- No easy way to manage several screenshots taken in quick succession

**Frames** is a minimal, native-feeling Mac utility that fixes this one problem — nothing more.

---

## 2. Core Features

1. **Full Screenshot** — capture the entire screen
2. **Area Screenshot** — capture a user-selected region, with support for taking several in sequence
3. **Scrolling Screenshot** — capture a full scrollable page/window as one continuous image

*(Screen recording has been dropped from scope — macOS's native screen recording covers this need.)*

---

## 3. Feature Details

### 3.1 Full Screenshot
- Trigger: user's chosen hotkey (default = system default, e.g. ⇧⌘4, unless already taken — see §6)
- Behavior: identical capture area/quality as native macOS screenshot
- Result: a small preview card appears in the bottom-right corner of the screen, inset with the same margin as the native macOS screenshot thumbnail
- **Card layout:**
  - Top-left: Cancel/dismiss (X) button — **discards the screenshot entirely**, nothing is saved anywhere
  - Top-right: Edit/Annotate button — opens the screenshot in a larger annotation window (the corner card itself is too small to edit in)
  - Center: two circular action buttons — **Copy** and **Save**
- **Auto-dismiss:** card remains for **60 seconds** (vs. macOS's default 10s), then automatically saves to Desktop
- **Copy action:** copies image to the macOS clipboard only — nothing is written to disk. Card dismisses after copying.
- **Save action:** saves directly to Desktop, with a brief on-screen confirmation label (e.g. "Saved to Desktop"). Card dismisses after saving.
- **File naming:** follows macOS's own convention, e.g. `Screenshot 2026-08-20 at 3.42.11 PM.png`, so files behave predictably alongside native screenshots and never silently overwrite each other

### 3.2 Area (Multi-)Screenshot
- Same capture and card behavior as Full Screenshot
- Supports taking **up to 5 screenshots in sequence** without them replacing each other
- Additional screenshots **stack** on top of the previous cards in the corner (offset ~8–10px per card, like a physical stack)
- **On hover:** the stack fans out so all 5 previews are visible at once, each with its own Cancel / Save / Copy / Edit controls
- Each card in the stack can be individually saved, copied, edited, or dismissed
- **Drag and drop:** any card (single or from the stack) can be dragged directly out into another app (works with any target app)
- **Limit reached behavior:** once 5 screenshots are active, taking another triggers a small popup telling the user to clear/save existing ones first (e.g. "Limit reached — save or clear a screenshot to take another"). Capture is blocked until a slot frees up, nothing is silently dropped or auto-cleared.
- **Critical technical requirement — self-capture exclusion:** the corner card / stacked cards must be **excluded from all subsequent screenshots**. If a user takes screenshot #2 while card #1 is still showing in the bottom-right corner, card #1 must not appear in the newly captured image. (On macOS this is achievable by excluding Frames' own overlay window from the capture, e.g. via `CGWindowListCreateImage` window exclusion or `SCContentFilter` excluding windows when using ScreenCaptureKit.)

### 3.3 Scrolling Screenshot
- User selects the capture area, then the app automatically scrolls and stitches the capture
- User can define a **maximum scroll length** for the capture, configurable in Settings, with an option to apply per-capture as well
- **First-use only:** a short onboarding popup explains how scrolling capture works, shown once
- **Result handling differs from the other modes:** instead of a corner card, the finished scrolling screenshot opens directly in a **modal window** with the full action set — Save, Copy, Delete, Edit/Annotate, and drag-and-drop
- Does **not** count toward the 5-screenshot corner-card limit, since it never enters the stack

---

## 4. Shared Behaviors (All Screenshot Modes)

- **No history / no library:** Frames does not retain any screenshot log or storage beyond the active preview cards, to avoid storage overhead
- **Storage limit:** max 5 active screenshots at once across modes
- **Auto-save on timeout:** any un-actioned card auto-saves to Desktop after 60 seconds and clears from the app
- **Editing:** an Edit button opens a basic annotation toolset — arrow, text, highlight, blur, and crop. Kept minimal by design; more tools can be added later.
- **Drag and drop:** works from any card into any other app
- **Launch at login:** Frames launches automatically at login (toggle available in Settings if the user wants to turn it off)

---

## 5. Design Direction

- Must strictly follow **Apple Human Interface Guidelines (HIG)**
- Should look and feel like a first-party Apple utility — not a third-party app
- Use **San Francisco** (Apple's system font) throughout
- Extremely minimal visual language — no unnecessary chrome, animation, or decoration
- **Settings window:** small, fixed-size window matching the scale/feel of macOS's "About This Mac" panel, with two sections:
  1. **Hotkeys** — configure shortcuts for each capture mode
  2. **General Settings** — scroll-length defaults, save location behavior, etc.

---

## 6. Hotkeys & Permissions

- Each capture mode (Full, Area, Scrolling) gets its own configurable hotkey
- **Default hotkeys:** mirror the existing macOS defaults so there's zero learning curve; users only need to change them if they choose to
- **Conflict detection:** if a user tries to assign a hotkey already in use elsewhere on the system, show a clear warning message rather than silently overriding it
  - Where feasible, suggest an available alternative shortcut
- **Settings UX:** the hotkey configuration screen should visually surface the current bindings and make it obvious how to change them, without requiring a tutorial
- **Permissions:** app must request macOS Screen Recording permission (and any other required system permissions) with a clear, native-style prompt explaining why it's needed, following Apple's standard permission-request pattern
- **Permission denied/revoked:** if the user denies or later revokes Screen Recording permission, capture attempts should show an alert with a direct link to System Settings → Privacy & Security → Screen Recording, rather than failing silently

---

## 7. Explicitly Out of Scope

- No screenshot history or library
- No cloud sync or account system
- No Mac App Store distribution (direct download from own website)
- No screen recording (relying entirely on macOS's native tool)

---

## 8. Decisions Log

| # | Item | Decision |
|---|------|----------|
| 1 | Screen recording | Dropped — out of scope |
| 2 | Annotation toolset | Arrow, text, highlight, blur, crop |
| 3 | 5-screenshot limit exceeded | Blocking popup; user must save/clear a slot first |
| 4 | App icon / branding | Basic placeholder icon for now; revisit later |
| 5 | Menu bar presence | **Assumption:** yes, a minimal menu bar icon for quick access to Settings and Quit — standard for this app category and needed since there's no Dock-first UI. Flag if you'd rather run fully headless. |
| 6 | Launch at login | Yes, on by default, toggle in Settings |
| 7 | Multi-display behavior | **Assumption:** capture card appears on the display where the screenshot was taken (matches native macOS behavior). Flag if you want it to always appear on the main display instead. |

Items 5 and 7 are reasonable defaults rather than confirmed answers — flag them if you want something different, otherwise the build proceeds as stated.

---

## 8a. Two Things That Need Your Attention Before Sending This Off

**1. Code signing & notarization (important — will block launch if skipped)**
Since you're distributing outside the Mac App Store, macOS Gatekeeper will show a "developer cannot be verified" warning — or block the app outright on newer macOS versions — unless it's signed with an Apple Developer ID and notarized by Apple. This requires a **paid Apple Developer account ($99/year)**. No-code tools can help you write the app, but you (or the tool, if it supports it) still need to run `codesign` + `notarytool` as a final packaging step before you put the download on your website. Worth deciding now, since it affects how you distribute the final build — not something to discover after the 3 hours are up.

**2. Hotkey conflict detection has a real limitation**
macOS doesn't expose a system-wide list of every hotkey every app has registered — Frames can reliably detect conflicts with **macOS's own built-in shortcuts** (System Settings → Keyboard → Shortcuts), but it generally **cannot see** custom global hotkeys registered by other third-party apps. Worth setting expectations with your no-code tool: build the conflict check against system shortcuts, and treat "detect any app's hotkey" as a stretch goal rather than a guarantee.

---

## 9. Build Plan — Under 3 Hours

Sectioned for handing to a no-code/AI dev tool (Claude Code, Codex, Google Antigravity) as sequential prompts. Each phase is a self-contained prompt; build and test one before moving to the next.

### Phase 1 — Project Shell & Permissions (0:00–0:25)
Set up a native macOS app (SwiftUI, menu-bar-only, no Dock icon unless a window is open). Add:
- App entry point, empty menu bar icon with a "Settings" and "Quit" menu
- Screen Recording permission request flow (native macOS prompt) triggered on first capture attempt, with a clear explanation label
- Launch-at-login toggle wired up (default: on)

### Phase 2 — Full Screenshot Capture + Corner Card (0:25–1:10)
- Implement full-screen capture triggered by a hotkey (default ⇧⌘4, using the system's existing shortcut unless remapped)
- Build the bottom-right corner card: X (cancel, top-left), Edit (top-right), Copy + Save (center, circular)
- Copy → clipboard only; Save → Desktop with a "Saved to Desktop" confirmation label
- 60-second auto-dismiss timer → auto-saves to Desktop on timeout
- **Capture exclusion:** ensure Frames' own overlay window is excluded from any screenshot it takes (critical — test by taking a screenshot while a card is visible)

### Phase 3 — Area Screenshot + Stacking (1:10–2:00)
- Add area-selection capture (drag-to-select region), reusing the corner card from Phase 2
- Support up to 5 simultaneous cards, stacked with ~8–10px offset
- On hover, stack fans out to show all cards individually, each with its own Copy/Save/Edit/Cancel
- Drag-and-drop of any card into another app
- Limit-reached popup when a 6th capture is attempted while 5 are active

### Phase 4 — Scrolling Screenshot (2:00–2:35)
- Area selection triggers auto-scroll + stitch capture
- Configurable max scroll length in Settings
- First-use onboarding popup (shown once, then never again)
- Result opens directly in a modal window (not the corner card) with Save/Copy/Delete/Edit/drag-and-drop

### Phase 5 — Settings, Hotkeys & Polish (2:35–3:00)
- Settings window sized like "About This Mac," two sections: Hotkeys and General
- Hotkey remapping UI with conflict detection against **macOS's built-in system shortcuts** (not third-party apps — see §8a) + a clear warning popup, and an alternative-shortcut suggestion where feasible
- Apply HIG-consistent styling throughout: San Francisco font, native spacing/materials, minimal chrome
- Final pass: confirm no history/cache is being written anywhere, confirm 60s timers and 5-screenshot cap behave correctly
- **Packaging:** sign and notarize the build with your Apple Developer ID before uploading to your website (see §8a) — an unsigned .app will trigger Gatekeeper warnings for anyone who downloads it

---

## 10. Next Step

Brief is fully resolved and ready for execution. Use each Phase in Section 9 as a standalone prompt for your no-code/AI dev tool, testing after each phase before moving on.
