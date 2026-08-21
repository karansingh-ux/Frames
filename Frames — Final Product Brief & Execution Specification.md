# Frames — Final Product Brief & Execution Specification

## 1. Product Overview

**Frames** is a native macOS screenshot utility designed to solve one specific problem:

> **Take screenshots quickly, keep them immediately accessible, and avoid unnecessary Desktop clutter.**

The problem with the native macOS screenshot workflow is that the screenshot preview disappears after a few seconds. If the user wants to paste or drag the screenshot into another application after that, they have to find the automatically saved file on the Desktop.

Frames removes that friction.

The product should feel:

- Native to macOS
- Minimal
- Fast
- Obvious
- Unobtrusive
- Familiar
- Extremely easy to use

Frames should **not feel like a complicated third-party screenshot application**.

---

# 2. Platform & Distribution

Frames will be a **native macOS application**.

### Compatibility

Frames should support **Mac computers from 2018 onward**, covering both Intel and Apple Silicon Macs where technically possible.

The minimum supported macOS version should be determined during implementation based on the APIs required, while maintaining the 2018+ hardware requirement.

### Distribution

Frames will **not initially be distributed through the Mac App Store**.

It will be distributed directly through the Frames website as a free download.

Because it will be distributed outside the Mac App Store, the implementation must account for:

- macOS Gatekeeper
- Code signing
- Notarization
- Appropriate permission requests
- A clean first-launch experience

The goal is that a normal user can download Frames from the website and install/use it without needing technical knowledge.

---

# 3. Core Features

Frames will initially contain **three screenshot features**:

1. Full-screen screenshot
2. Area/section screenshot
3. Scrolling/long screenshot

### Explicitly excluded

**Screen recording is not part of Frames.**

macOS already provides good native screen-recording functionality, so Frames should not duplicate it.

---

# 4. Full-Screen Screenshot

When the user activates the full-screen screenshot shortcut:

1. Frames captures the entire screen.
2. The screenshot appears in the **bottom-right corner**.
3. The position and approximate size should feel similar to the native macOS screenshot preview.
4. The screenshot remains available for **60 seconds**.
5. If the user does nothing for 60 seconds, the preview disappears.
6. Once the 60 seconds expire, the screenshot is automatically saved to the **Desktop**.

This means the screenshot is temporarily available without creating a Desktop file immediately.

### Important behavior

The 60-second period is essentially the user's opportunity to:

- Copy
- Save
- Edit
- Delete
- Drag and drop

If they do nothing, Frames automatically saves the screenshot to the Desktop after 60 seconds.

---

# 5. Screenshot Preview Card

The bottom-right screenshot preview should resemble the native macOS screenshot preview as closely as practical.

The card should contain clear, obvious controls.

### Controls

- **Delete / Cancel**
- **Copy**
- **Save**
- **Edit / Annotate**
- **Drag and Drop**

The controls should be visually understandable without requiring instructions.

### Save

When the user presses **Save**:

- The screenshot is immediately saved to the Desktop.
- A small visual confirmation should appear, such as:
  **"Saved to Desktop"**
- The interaction should then make it obvious that the screenshot has been successfully saved.

### Copy

When the user presses **Copy**:

- The screenshot is copied directly to the **macOS clipboard**.
- It should **not be saved to the Desktop** merely because the user copied it.
- The user can immediately paste it into another application.

### Delete

Delete removes the temporary screenshot without saving it.

### Recommendation

The Save and Copy actions should be visually differentiated enough that users cannot easily confuse them.

---

# 6. No Screenshot History

Frames will **not maintain a screenshot history**.

There should be:

- No cloud storage
- No account
- No screenshot library
- No permanent in-app history
- No server-side screenshot storage

The only temporary screenshot state exists to support the active screenshot workflow.

### Screenshot Limit

Frames supports a maximum of **5 active screenshots** at one time.

This limit applies across the temporary screenshot stack.

This keeps the product lightweight and prevents Frames from becoming a screenshot-management application.

---

# 7. Area / Section Screenshot

The second feature allows users to select a specific area of the screen.

The flow should feel similar to the native macOS area screenshot experience:

1. User activates the shortcut.
2. User selects an area.
3. Frames captures the selected area.
4. The screenshot appears in the bottom-right corner.
5. It remains available for 60 seconds.
6. After 60 seconds, it is automatically saved to the Desktop if the user has not interacted with it.

The user can:

- Copy
- Save
- Delete
- Edit/Annotate
- Drag and drop

---

# 8. Multiple Screenshot Stack

Users should be able to take multiple screenshots without needing to deal with each screenshot immediately.

For example:

1. Capture screenshot 1.
2. Capture screenshot 2.
3. Capture screenshot 3.
4. Capture screenshot 4.
5. Capture screenshot 5.

The screenshots should appear as a **single stacked group** in the bottom-right corner.

### Maximum

The maximum number of active screenshots is:

**5**

No sixth active screenshot should be allowed.

### Recommendation

If the user attempts to take a sixth screenshot while five are active, Frames should provide a simple, non-intrusive message such as:

> **5 screenshots active. Save, copy, or remove one to continue.**

Do not silently delete an existing screenshot.

---

# 9. Screenshot Stack Interaction

When screenshots are stacked:

- The cards should overlap.
- Approximately **8–10 px** of each underlying card should remain visible.
- The stack should clearly communicate that multiple screenshots exist.

### Hover Interaction

When the user hovers over the stack:

- The stack should expand.
- All active screenshots should become visible.
- The interaction should feel natural and lightweight.
- The user should immediately understand which screenshot they are interacting with.

Each screenshot retains its own actions:

- Copy
- Save
- Delete
- Edit
- Drag and Drop

The user should be able to independently manage every screenshot.

---

# 10. Drag and Drop

Drag and drop is a core part of Frames.

A screenshot should be draggable directly from its preview card into **any application that accepts images/files through standard macOS drag-and-drop**.

Examples include:

- Messages
- Mail
- Slack
- Notes
- Design applications
- Documents
- Browsers
- Other compatible applications

The user should not have to save the screenshot to the Desktop first.

### Recommendation

The implementation should use native macOS drag-and-drop behavior wherever possible rather than creating a custom drag interaction.

The experience should feel identical to dragging a normal file/image on macOS.

---

# 11. Expanded Screenshot View

Clicking/opening a screenshot should display a larger screenshot window/modal.

The expanded view should provide:

- Copy
- Save
- Delete
- Edit/Annotation
- Drag and Drop

The interface should remain minimal.

There should be no unnecessary screenshot-management features.

---

# 12. Scrolling / Long Screenshot

The third feature is **Scrolling Screenshot**.

The purpose is to capture content that extends beyond the visible screen.

Examples:

- Long webpages
- Documents
- Long application content
- Scrollable interfaces

### Flow

1. User activates the scrolling screenshot shortcut.
2. User selects the capture area.
3. Frames begins the scrolling capture.
4. Frames automatically scrolls through the selected content.
5. Frames captures the content during the scrolling process.
6. The captured sections are combined into one long screenshot.
7. The user receives the final long screenshot in an expanded window.

---

# 13. Long Screenshot Length

The user should be able to specify the desired capture length.

This should be configurable within the application settings.

The UI should make the option understandable without requiring technical knowledge.

For example, the user could choose a predefined or configurable capture length rather than needing to understand technical scrolling parameters.

### Recommendation

Prefer simple human-facing options such as:

- Short
- Medium
- Long
- Custom

rather than exposing technical values unless necessary.

The underlying implementation can use an exact length, but the user experience should remain simple.

---

# 14. First-Time Long Screenshot Guidance

The first time a user uses Scrolling Screenshot, Frames should briefly explain how it works.

The message should be:

- Short
- Clear
- Contextual
- Dismissible

It should explain what the user needs to do without becoming a tutorial.

After the user understands the feature, the guidance should not repeatedly interrupt them.

---

# 15. Long Screenshot Result

Unlike normal screenshots, a long screenshot should **not appear as a small bottom-right temporary card first**.

Once the scrolling capture is complete, Frames should directly open the result in the expanded screenshot window.

The available actions are:

- Copy
- Save
- Delete
- Edit/Annotate
- Drag and Drop

---

# 16. Annotation / Editing

Frames should provide a basic editing/annotation capability.

The initial scope should remain intentionally small.

The exact annotation tools should be finalized before implementation, but the editing experience should prioritize common screenshot actions rather than becoming a full image editor.

Potential initial tools:

- Crop
- Text
- Arrow
- Rectangle
- Circle
- Freehand
- Blur/redaction

### Recommendation

Do not build a large image editor in V1.

The editing experience should solve the most common screenshot annotation needs while keeping Frames lightweight.

---

# 17. Keyboard Shortcuts

Frames should provide configurable keyboard shortcuts for:

- Full-screen screenshot
- Area screenshot
- Scrolling screenshot

The application should use sensible default shortcuts that are familiar and unlikely to conflict with macOS.

Users can change the shortcuts if they want.

---

# 18. Shortcut Conflict Detection

Frames must detect shortcut conflicts.

If the user enters a shortcut that is already being used, Frames should clearly communicate the conflict.

The UX should be obvious without requiring the user to understand how keyboard shortcuts work technically.

For example:

> **This shortcut is already in use. Choose another shortcut.**

### Preferred behavior

If a shortcut is known to conflict with a macOS shortcut or another Frames shortcut:

- Clearly indicate the conflict.
- Explain why it cannot be used where possible.
- Let the user choose another shortcut.

Frames should **not silently override system behavior**.

### Optional Enhancement

If technically reliable, Frames can suggest alternative shortcuts when a conflict occurs.

However, this should only be implemented if the system can determine conflicts accurately.

Do **not** build a complicated shortcut-database system just to provide suggestions.

---

# 19. Settings

Frames should have a **small, minimal settings window**.

The overall scale should feel similar to a compact native macOS utility window, rather than a full-size application.

The settings should contain two primary sections:

## Hotkeys

- Full-screen screenshot
- Area screenshot
- Scrolling screenshot

Each should clearly display its current shortcut and provide an obvious way to change it.

## Settings

Only include settings that are actually necessary.

Potential settings include:

- Screenshot duration
- Scrolling screenshot length
- Other essential screenshot behavior

Avoid creating settings simply because they are technically possible.

---

# 20. UX Principle: No Learning Curve

This is one of the most important product requirements.

**Frames should require almost no learning.**

The user should be able to open it and immediately understand how it works.

The application should follow familiar macOS conventions wherever possible.

### For example:

If a user sees:

**Copy · Save · Edit · Delete**

the meaning should be immediately obvious.

If a setting can be changed, the UI should make the interaction obvious.

If a shortcut can be changed, the UI should visually indicate:

- What shortcut is currently assigned
- How to change it
- Whether the new shortcut is valid
- Whether there is a conflict

Do not rely on hidden gestures or undocumented behavior.

### Product rule

> **If the user needs to learn how Frames works, the UX should be reconsidered first.**

---

# 21. Permissions

Frames must properly handle all macOS permissions required by the actual implementation.

The application should:

1. Detect missing permissions.
2. Explain why the permission is needed.
3. Provide an obvious action to grant it.
4. Detect when permission has been granted.
5. Continue the workflow without requiring the user to restart unnecessarily where possible.

Permission requests should feel like a normal macOS experience.

The application should never leave the user wondering:

> "Why isn't this working?"

---

# 22. Error & Edge-Case Handling

Frames should gracefully handle cases where screenshot capture cannot be completed.

For example:

- Screen capture permission is unavailable.
- A selected area cannot be captured.
- Scrolling capture cannot proceed.
- The target application does not support the expected scrolling behavior.
- A shortcut conflicts with another shortcut.
- Five screenshots are already active.
- A drag-and-drop operation is unsupported by the destination application.

Errors should be communicated using **short, human-readable messages**.

Avoid technical error messages whenever possible.

---

# 23. Automatic Desktop Saving

This is an important part of the product behavior.

Frames does **not immediately save every screenshot to the Desktop**.

Instead:

### Immediately after capture

Screenshot exists temporarily inside Frames.

### During 60 seconds

User can:

- Copy
- Save
- Delete
- Edit
- Drag and Drop

### After 60 seconds

If the screenshot has not been dealt with:

**Frames automatically saves it to the Desktop.**

The user should receive a subtle indication that the screenshot has been saved.

This preserves the safety of the native macOS workflow while giving the user significantly more time to interact with the screenshot.

---

# 24. Visual Design

Frames should follow Apple's Human Interface Guidelines and native macOS conventions as closely as practical.

The design should use:

- Native macOS typography
- Native controls where appropriate
- Appropriate spacing
- Subtle animations
- Native window behavior
- Native menus where appropriate
- Native permission flows
- Native drag-and-drop behavior

The product should feel like an Apple utility rather than a web application wrapped in a Mac window.

### Avoid

- Excessive gradients
- Large colorful dashboards
- Excessive shadows
- Unnecessary illustrations
- Complex navigation
- Gamification
- Account creation
- Cloud features
- Unnecessary branding inside the workflow

---

# 25. Privacy & Storage Philosophy

Frames should be local-first.

The application should not require:

- User accounts
- Cloud storage
- Online screenshot history
- Servers for screenshot storage

Screenshots should remain on the user's Mac.

This is especially important because the product's purpose is to provide a lightweight utility rather than become a screenshot-storage service.

---

# 26. Technical Product Principle

Frames must use **real native macOS functionality** wherever necessary.

The development agents should not create fake or simulated functionality simply because it is easier to demonstrate.

Every major feature must work in the actual macOS environment:

- Screen capture
- Area selection
- Clipboard
- Desktop saving
- Drag and drop
- Keyboard shortcuts
- Scrolling capture
- Permissions
- Settings
- Temporary screenshot management

---

# 27. AI-Assisted Development

The product will be designed and developed with the help of AI/no-code-assisted development tools.

Primary tools include:

- **Codex**
- **Claude Code**
- **Google Antigravity**

The product owner is a **designer, not a programmer**, so development prompts must be written in a way that allows these tools to perform the technical implementation with minimal manual coding.

The implementation process should therefore be:

**Product brief → architecture → implementation prompts → development → testing → refinement**

Prompts should be specific enough to prevent the development agents from inventing features or making assumptions.

---

# 28. Development Guardrails

The development agents should follow these rules:

1. Do not add features that are not in the approved scope.
2. Do not turn Frames into a general-purpose screenshot manager.
3. Do not add user accounts.
4. Do not add cloud storage.
5. Do not add screenshot history.
6. Do not add screen recording.
7. Do not create unnecessary settings.
8. Prefer native macOS APIs and UI patterns.
9. Prioritize reliability over visual effects.
10. Never implement a fake version of a core feature.
11. Handle permissions properly.
12. Handle errors gracefully.
13. Test the actual application on supported Macs.
14. Maintain the 5-screenshot limit.
15. Maintain the 60-second temporary screenshot behavior.
16. Preserve the automatic Desktop fallback.
17. Keep the interface extremely simple.

---

# 29. Core User Flow

The ideal experience should be:

**Press shortcut → Capture → Screenshot appears → Copy / Save / Edit / Drag → Done**

Or:

**Press shortcut → Capture → Do nothing → 60 seconds → Automatically saved to Desktop**

There should be no unnecessary steps between capture and action.

---

# 30. Final Product Philosophy

Frames is not trying to replace every screenshot feature on macOS.

It is solving one specific frustration:

> **"I just took a screenshot. I want to use it right now without having to chase the file down on my Desktop."**

Everything in the product should support that idea.

The product should be:

**Simple. Native. Fast. Temporary. Useful.**

If a feature makes Frames more complicated without directly improving this workflow, it should probably not be included.

---

# 31. Final Open Decisions for Implementation

The major product decisions are now sufficiently defined to move into execution.

A few implementation-level decisions can be left to the development agents, provided they follow the product principles above:

### Scrolling Capture Reliability

Scrolling screenshots are technically more complex than normal screenshots because different applications/websites behave differently.

The implementation should first use the most reliable native macOS approach available and clearly handle applications where automated scrolling cannot work reliably.

### Drag-and-Drop Implementation

The technical implementation should use native macOS drag-and-drop mechanisms and should make the screenshot available in a format compatible with normal applications.

The user should not need to understand how this works.

### Temporary Files

Frames may need to create temporary local files to support certain native macOS operations such as drag-and-drop.

Those temporary files should be managed automatically and should not become a user-visible screenshot history.

### Desktop File Naming

Screenshots automatically saved to the Desktop should use a sensible, predictable naming convention similar to normal macOS screenshots.

The exact naming format can follow the native macOS convention wherever practical.

### Auto-Save Safety

If a screenshot has already been explicitly saved by the user, Frames should not create a duplicate Desktop copy when its 60-second timer expires.

Likewise, if it has been deleted, it should not later reappear.

---

# 32. V1 Success Criteria

Frames V1 is successful if a normal Mac user can:

- Download it from the Frames website.
- Install it without technical knowledge.
- Grant required permissions without confusion.
- Immediately understand the screenshot shortcuts.
- Capture a full-screen screenshot.
- Capture a selected area.
- Capture a long/scrolling screenshot.
- Copy a screenshot directly to the clipboard.
- Save a screenshot directly to the Desktop.
- Drag a screenshot directly into another application.
- Manage up to five temporary screenshots.
- Understand the screenshot stack without instructions.
- Change shortcuts without confusion.
- Receive clear feedback when something goes wrong.
- Use the application without needing a tutorial.

Most importantly:

**The user should feel that Frames simply behaves like a natural part of macOS.**

---

# 33. Next Execution Phase

The product brief is now ready to move into implementation.

The next phase should **not immediately start writing random code**.

The recommended execution sequence is:

1. Define the native macOS technical architecture.
2. Identify the required Apple frameworks/APIs.
3. Define the application lifecycle and background behavior.
4. Define the screenshot capture architecture.
5. Define temporary screenshot storage and the 60-second lifecycle.
6. Define the screenshot stack architecture.
7. Define clipboard and Desktop saving.
8. Define native drag-and-drop.
9. Define scrolling screenshot architecture.
10. Define keyboard shortcut registration and conflict handling.
11. Define permission handling.
12. Define the minimal UI structure.
13. Define the settings architecture.
14. Define the annotation/editor scope.
15. Define error and edge-case behavior.
16. Create the implementation prompts for Codex, Claude Code, and Google Antigravity.
17. Build feature-by-feature.
18. Test each feature on real supported Macs.
19. Package, sign, notarize, and prepare the website distribution.

The development agents should be instructed to **stop and flag a technical limitation rather than silently inventing a workaround that violates the product brief**.