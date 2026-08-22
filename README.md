# Frames — Lightweight, Native macOS Screenshot Utility

[![Platform](https://img.shields.io/badge/platform-macOS%2013.0%2B-blue.svg)](https://apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange.svg)](https://swift.org)
[![Architecture](https://img.shields.io/badge/arch-Universal%20(arm64%20%2B%20x86__64)-purple.svg)]()
[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)

**Frames** is a native, ultra-fast macOS menu-bar screenshot utility designed to eliminate desktop clutter. It keeps screenshots temporarily accessible in a floating preview stack (up to 5 cards) in the bottom-right corner, giving you time to copy, save, annotate, or drag-and-drop before anything touches your disk.

---

## ⚡️ Key Features

* **Instant Full-Screen Capture (`⌘3`):** Capture any active monitor with zero latency in full Retina resolution.
* **Pixel-Perfect Area Marquee (`⌘4`):** Drag an area with crosshair reticle and live dimension HUD (`W × H px`).
* **Floating Stacks (Max 5 Cards):** Screenshots appear in an unobtrusive bottom-right floating card stack anchored 24px from screen edges.
* **Vertical Upward Expansion:** Click the stack counter badge to expand cards upward with clean 12px spacing.
* **Native Multi-Image Drag & Drop:** Drag the collapsed stack to transfer all active screenshots simultaneously into **Slack**, **Figma**, **ChatGPT**, **Claude**, **Notes**, **Messages**, or **Finder** with an automatic **“X Images”** count badge.
* **Auto-Dismissal on Drop:** Dropping a card into any target chat or app immediately dismisses the preview card with zero manual cleanup required.
* **Zero History / Zero Disk Clutter:** Pure in-memory ephemeral architecture. No databases, no background libraries, no cloud sync, and zero telemetry.
* **Configurable Lifecycles:** Configurable countdown timer (60s, 90s, 120s) with pause-on-hover and auto-save fallback.
* **Instant Native Shutter Sound:** Satisfying macOS camera shutter audio feedback on capture (with General Settings toggle).
* **Automatic Update Checking:** Checks for new releases via the GitHub Releases API with one-click browser download prompts.

---

## ⌨️ Default Shortcuts

| Shortcut | Action | Description |
|---|---|---|
| `⌘3` | **Capture Full Screen** | Captures active display; shows corner preview card |
| `⌘4` | **Capture Area…** | Interactive selection crop with dimension HUD |

*Customizable in **Frames Settings → Hotkeys** with live conflict detection against system shortcuts.*

---

## 🚀 Installation & Download

### Option 1: Direct Download (Ready to Run)
1. Download the latest **`Frames.dmg`** from the [Releases](https://github.com/karansingh-ux/Frames/releases) page.
2. Open `Frames.dmg` and drag **Frames.app** to your `/Applications` folder.
3. **First-Time macOS Launch Note:**  
   Because Frames is a free, independent open-source project without a paid corporate certificate:
   * **Right-click `Frames.app` in Applications → Select Open → Click Open** (only needed once on first launch).  
   * *(Alternatively, go to macOS **System Settings → Privacy & Security** and click **"Open Anyway"**).*
4. Grant **Screen Recording** permission when prompted in macOS System Settings.

---

## 🛠 Building from Source

### Requirements
* macOS 14.0 (Sonoma) or later
* Xcode 15+ / Command Line Tools with Swift 5.9+

### Build Steps
```bash
# Clone repository
git clone https://github.com/karansingh-ux/Frames.git
cd Frames

# Run test suite
swift run FramesVerification

# Build release app bundle and export packages (DMG & ZIP)
./Scripts/build_app.sh
```

Compiled application bundle will be output to `build/Frames.app` and distribution files to `Export/`.

---

## 🤝 Contributing

Contributions, bug reports, and feature suggestions are welcome!

### Contributor Agreement
By submitting a Pull Request or contributing code to the Frames repository, you agree that your contributions will be licensed under the project's **GNU General Public License v3.0 (GPL-3.0)** and grant the project owner the right to include them in official project distributions and releases.

To contribute:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'Add amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

---

## 📄 License & Trademark Notice

* **Source Code:** Licensed under the [GNU General Public License v3.0 (GPL-3.0)](LICENSE).
* **Trademark & Branding:** The project name **"Frames"**, official logos, icons, and brand design assets remain the exclusive property of Karan Singh.
