import Cocoa
import Carbon

public final class HotkeyManager {
    public static let shared = HotkeyManager()
    
    private var hotKeyRefs: [UInt32: EventHotKeyRef] = [:]
    private var handlers: [UInt32: () -> Void] = [:]
    private var eventHandlerInstalled = false
    
    public enum HotkeyIdentifier: UInt32 {
        case fullScreen = 1001
        case area = 1002
    }
    
    private init() {
        installCarbonEventHandler()
    }
    
    public func register(id: HotkeyIdentifier, combo: KeyCombo, handler: @escaping () -> Void) {
        unregister(id: id)
        handlers[id.rawValue] = handler
        
        var gMyHotKeyID = EventHotKeyID()
        gMyHotKeyID.signature = OSType(0x4652414D) // 'FRAM'
        gMyHotKeyID.id = id.rawValue
        
        let carbonModifiers = carbonModifiers(from: combo.modifierFlags)
        var hotKeyRef: EventHotKeyRef?
        
        let status = RegisterEventHotKey(
            UInt32(combo.keyCode),
            carbonModifiers,
            gMyHotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
        
        if status == noErr, let ref = hotKeyRef {
            hotKeyRefs[id.rawValue] = ref
        } else {
            NSLog("[Frames] Failed to register Carbon hotkey \(id): status \(status)")
        }
    }
    
    public func unregister(id: HotkeyIdentifier) {
        if let ref = hotKeyRefs[id.rawValue] {
            UnregisterEventHotKey(ref)
            hotKeyRefs.removeValue(forKey: id.rawValue)
        }
        handlers.removeValue(forKey: id.rawValue)
    }
    
    public func registerAllFromPreferences() {
        let prefs = AppPreferences.shared
        register(id: .fullScreen, combo: prefs.fullScreenHotkey) {
            AppState.shared.triggerFullScreenCapture()
        }
        register(id: .area, combo: prefs.areaHotkey) {
            AppState.shared.triggerAreaCapture()
        }
    }
    
    private func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var carbonFlags: UInt32 = 0
        if flags.contains(.command) { carbonFlags |= UInt32(cmdKey) }
        if flags.contains(.option) { carbonFlags |= UInt32(optionKey) }
        if flags.contains(.shift) { carbonFlags |= UInt32(shiftKey) }
        if flags.contains(.control) { carbonFlags |= UInt32(controlKey) }
        return carbonFlags
    }
    
    private func installCarbonEventHandler() {
        guard !eventHandlerInstalled else { return }
        
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        let handlerCallback: EventHandlerUPP = { (_, inEvent, _) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(
                inEvent,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )
            
            if status == noErr {
                DispatchQueue.main.async {
                    HotkeyManager.shared.dispatchHotkey(id: hotKeyID.id)
                }
                return noErr
            }
            return OSStatus(eventNotHandledErr)
        }
        
        InstallEventHandler(
            GetEventDispatcherTarget(),
            handlerCallback,
            1,
            &eventType,
            nil,
            nil
        )
        
        eventHandlerInstalled = true
    }
    
    private func dispatchHotkey(id: UInt32) {
        if let handler = handlers[id] {
            handler()
        }
    }
}
