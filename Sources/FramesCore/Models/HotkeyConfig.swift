import Foundation
import AppKit

public struct KeyCombo: Codable, Equatable, Hashable {
    public var keyCode: UInt16
    public var modifiers: UInt // NSEvent.ModifierFlags raw value
    
    public init(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.modifiers = modifiers.rawValue
    }
    
    public var modifierFlags: NSEvent.ModifierFlags {
        return NSEvent.ModifierFlags(rawValue: modifiers)
    }
    
    public var displayString: String {
        var str = ""
        let flags = modifierFlags
        if flags.contains(.control) { str += "⌃" }
        if flags.contains(.option) { str += "⌥" }
        if flags.contains(.shift) { str += "⇧" }
        if flags.contains(.command) { str += "⌘" }
        
        str += KeyCodeHelper.string(for: keyCode)
        return str
    }
    
    // Default shortcuts
    // Full screenshot: Command + 3 (Keycode 20 is '3')
    public static let defaultFullScreen = KeyCombo(keyCode: 20, modifiers: [.command])
    // Area screenshot: Command + 4 (Keycode 21 is '4')
    public static let defaultArea = KeyCombo(keyCode: 21, modifiers: [.command])
}

public enum KeyCodeHelper {
    public static func string(for keyCode: UInt16) -> String {
        switch keyCode {
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 23: return "5"
        case 22: return "6"
        case 26: return "7"
        case 28: return "8"
        case 25: return "9"
        case 29: return "0"
        case 0: return "A"
        case 11: return "B"
        case 8: return "C"
        case 2: return "D"
        case 14: return "E"
        case 3: return "F"
        case 5: return "G"
        case 4: return "H"
        case 34: return "I"
        case 38: return "J"
        case 40: return "K"
        case 37: return "L"
        case 46: return "M"
        case 45: return "N"
        case 31: return "O"
        case 35: return "P"
        case 12: return "Q"
        case 15: return "R"
        case 1: return "S"
        case 17: return "T"
        case 32: return "U"
        case 9: return "V"
        case 13: return "W"
        case 7: return "X"
        case 16: return "Y"
        case 6: return "Z"
        case 49: return "Space"
        case 53: return "Esc"
        case 36: return "Return"
        default: return "Key(\(keyCode))"
        }
    }
}
