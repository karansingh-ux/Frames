import Foundation
import AppKit

public struct HotkeyConflict {
    public let conflictingName: String
    public let isSystemShortcut: Bool
}

public final class HotkeyConflictDetector {
    public static let shared = HotkeyConflictDetector()
    
    private init() {}
    
    // Known macOS built-in shortcuts
    private let systemShortcuts: [KeyCombo: String] = [
        // Spotlight: Cmd + Space
        KeyCombo(keyCode: 49, modifiers: [.command]): "Spotlight Search (⌘Space)",
        // Spotlight Finder: Option + Cmd + Space
        KeyCombo(keyCode: 49, modifiers: [.option, .command]): "Spotlight in Finder (⌥⌘Space)",
        // Native Full Screenshot: Cmd + Shift + 3
        KeyCombo(keyCode: 20, modifiers: [.command, .shift]): "macOS Native Full Screenshot (⇧⌘3)",
        // Native Selection Screenshot: Cmd + Shift + 4
        KeyCombo(keyCode: 21, modifiers: [.command, .shift]): "macOS Native Area Screenshot (⇧⌘4)",
        // Native Screen Utility: Cmd + Shift + 5
        KeyCombo(keyCode: 23, modifiers: [.command, .shift]): "macOS Native Capture Utility (⇧⌘5)",
        // Force Quit: Cmd + Option + Esc
        KeyCombo(keyCode: 53, modifiers: [.command, .option]): "Force Quit Applications (⌥⌘Esc)",
        // Lock Screen: Ctrl + Cmd + Q
        KeyCombo(keyCode: 12, modifiers: [.control, .command]): "Lock Screen (⌃⌘Q)"
    ]
    
    public func detectConflict(for combo: KeyCombo, excludingCurrentUsage: String? = nil) -> HotkeyConflict? {
        let prefs = AppPreferences.shared
        
        // Check internal Frames collisions
        if excludingCurrentUsage != "fullScreen" && combo == prefs.fullScreenHotkey {
            return HotkeyConflict(conflictingName: "Frames: Full-Screen Shortcut", isSystemShortcut: false)
        }
        if excludingCurrentUsage != "area" && combo == prefs.areaHotkey {
            return HotkeyConflict(conflictingName: "Frames: Area Screenshot Shortcut", isSystemShortcut: false)
        }
        
        // Check system shortcuts
        for (sysCombo, desc) in systemShortcuts {
            if sysCombo.keyCode == combo.keyCode && sysCombo.modifierFlags == combo.modifierFlags {
                return HotkeyConflict(conflictingName: desc, isSystemShortcut: true)
            }
        }
        
        return nil
    }
}
