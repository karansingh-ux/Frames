import SwiftUI
import AppKit

// MARK: - Minimal, Open Theme (Zero Container Boxes, Generous Spacing)
public enum FramesTheme {
    public static let canvasBg = Color(red: 8/255, green: 8/255, blue: 12/255)         // #08080C
    public static let brandElectric = Color(red: 3/255, green: 2/255, blue: 255/255)   // #0302FF
    public static let brandGlow = Color(red: 61/255, green: 59/255, blue: 255/255)     // #3D3BFF
    public static let brandAccent = Color(red: 91/255, green: 90/255, blue: 255/255)   // #5B5AFF
    public static let textPrimary = Color(red: 248/255, green: 250/255, blue: 252/255) // #F8FAFC
    public static let textSecondary = Color(red: 248/255, green: 250/255, blue: 252/255).opacity(0.60)
    public static let textMuted = Color(red: 248/255, green: 250/255, blue: 252/255).opacity(0.35)
    public static let pillBg = Color.white.opacity(0.06)
    public static let pillBorder = Color.white.opacity(0.08)
}

public struct SettingsView: View {
    @ObservedObject var prefs = AppPreferences.shared
    @ObservedObject var permissions = PermissionsManager.shared
    @State private var selectedTab: SettingsTab = .general
    
    public enum SettingsTab: String, CaseIterable, Identifiable {
        case general = "General"
        case shortcuts = "Shortcuts"
        case support = "Support"
        
        public var id: String { rawValue }
        
        public var iconName: String {
            switch self {
            case .general: return "gearshape.fill"
            case .shortcuts: return "command"
            case .support: return "heart.fill"
            }
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar Navigation (Minimal & Seamless)
            HStack(spacing: 8) {
                ForEach(SettingsTab.allCases) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedTab = tab
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 11, weight: .semibold))
                            Text(tab.rawValue)
                                .font(.system(size: 12, weight: selectedTab == tab ? .semibold : .medium))
                        }
                        .foregroundColor(selectedTab == tab ? .white : FramesTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(selectedTab == tab ? FramesTheme.brandElectric : Color.white.opacity(0.04))
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Text("v1.0.0")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(FramesTheme.textMuted)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.white.opacity(0.04)))
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Tab View Body (Open, Unboxed, Spacious)
            VStack {
                if selectedTab == .general {
                    GeneralSettingsSection()
                } else if selectedTab == .shortcuts {
                    ShortcutsSettingsSection()
                } else {
                    SupportSettingsSection()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .padding(.bottom, 20)
            
            Spacer(minLength: 0)
        }
        .frame(width: 480, height: 430)
        .background(FramesTheme.canvasBg)
        .preferredColorScheme(.dark)
    }
}

// MARK: - 1. General Settings Section (Open, Container-Free, Generous Spacing)
public struct GeneralSettingsSection: View {
    @ObservedObject var prefs = AppPreferences.shared
    @ObservedObject var permissions = PermissionsManager.shared
    
    private var currentFolderName: String {
        let path = prefs.saveDirectoryPath
        let url = URL(fileURLWithPath: path)
        if path.contains("Desktop") {
            return "Desktop"
        }
        return url.lastPathComponent
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Row 1: Save Location
            OpenSettingRow(title: "Save Location") {
                Button(action: selectFolder) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 11))
                            .foregroundColor(FramesTheme.brandAccent)
                        Text(currentFolderName)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(FramesTheme.textMuted)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 6).fill(FramesTheme.pillBg))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(FramesTheme.pillBorder, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            
            // Row 2: Save Format
            OpenSettingRow(title: "Save Format") {
                Picker("", selection: $prefs.saveFormat) {
                    ForEach(SaveFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 160)
            }
            
            // Row 3: After Capture
            OpenSettingRow(title: "After Capture") {
                Picker("", selection: $prefs.afterScreenshot) {
                    ForEach(AfterScreenshotAction.allCases) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 170)
            }
            
            // Row 4: Preview Lifetime
            OpenSettingRow(title: "Preview Lifetime") {
                Picker("", selection: $prefs.previewDuration) {
                    ForEach(PreviewDuration.allCases) { duration in
                        Text(duration.displayString).tag(duration)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 170)
            }
            
            // Row 5: Shutter Sound
            OpenSettingRow(title: "Camera Shutter Sound") {
                Toggle("", isOn: Binding(
                    get: { prefs.playSoundOnCapture },
                    set: { prefs.playSoundOnCapture = $0 }
                ))
                .toggleStyle(.switch)
                .controlSize(.mini)
            }
            
            // Row 6: Launch at Startup
            OpenSettingRow(title: "Launch at Startup") {
                Toggle("", isOn: Binding(
                    get: { prefs.launchAtLogin },
                    set: { newValue in
                        prefs.launchAtLogin = newValue
                        LaunchAtLoginManager.shared.setEnabled(newValue)
                    }
                ))
                .toggleStyle(.switch)
                .controlSize(.mini)
            }
            
            // Row 7: Screen Recording Permission
            OpenSettingRow(title: "Screen Recording") {
                if permissions.hasScreenCapturePermission {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 11))
                        Text("Granted")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(FramesTheme.textSecondary)
                    }
                } else {
                    Button("Grant Access") {
                        permissions.requestScreenCapturePermission()
                        permissions.openScreenCaptureSettings()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(FramesTheme.brandElectric)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .onAppear {
            permissions.checkPermissions()
        }
        .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
            permissions.checkPermissions()
        }
    }
    
    private func selectFolder() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose Screenshots Destination Folder"
        openPanel.prompt = "Select"
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK, let selectedURL = openPanel.url {
            prefs.saveDirectoryPath = selectedURL.path
        }
    }
}

// Single Open Setting Row without Box Container
public struct OpenSettingRow<Control: View>: View {
    let title: String
    let control: Control
    
    public init(title: String, @ViewBuilder control: () -> Control) {
        self.title = title
        self.control = control()
    }
    
    public var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(FramesTheme.textPrimary)
            
            Spacer()
            
            control
        }
    }
}

// MARK: - 2. Shortcuts Section (Open, Clean, Spacious)
public struct ShortcutsSettingsSection: View {
    @ObservedObject var prefs = AppPreferences.shared
    @State private var conflictMessage: String?
    
    public var body: some View {
        VStack(spacing: 20) {
            // Full Screen Shortcut
            OpenSettingRow(title: "Full-Screen Capture") {
                ShortcutButton(
                    combo: prefs.fullScreenHotkey,
                    usageKey: "fullScreen",
                    onChanged: { newCombo in
                        if let conflict = HotkeyConflictDetector.shared.detectConflict(for: newCombo, excludingCurrentUsage: "fullScreen") {
                            conflictMessage = "Conflict: \(conflict.conflictingName) is already using this shortcut."
                        } else {
                            conflictMessage = nil
                            prefs.fullScreenHotkey = newCombo
                            HotkeyManager.shared.registerAllFromPreferences()
                        }
                    }
                )
            }
            
            // Area Crop Shortcut
            OpenSettingRow(title: "Area Marquee Capture") {
                ShortcutButton(
                    combo: prefs.areaHotkey,
                    usageKey: "area",
                    onChanged: { newCombo in
                        if let conflict = HotkeyConflictDetector.shared.detectConflict(for: newCombo, excludingCurrentUsage: "area") {
                            conflictMessage = "Conflict: \(conflict.conflictingName) is already using this shortcut."
                        } else {
                            conflictMessage = nil
                            prefs.areaHotkey = newCombo
                            HotkeyManager.shared.registerAllFromPreferences()
                        }
                    }
                )
            }
            
            if let conflict = conflictMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 11))
                    Text(conflict)
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.yellow.opacity(0.12)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.yellow.opacity(0.3), lineWidth: 1))
            }
            
            Spacer(minLength: 10)
            
            Text("Click a shortcut button and press your preferred key combination.")
                .font(.system(size: 11))
                .foregroundColor(FramesTheme.textMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

public struct ShortcutButton: View {
    let combo: KeyCombo
    let usageKey: String
    let onChanged: (KeyCombo) -> Void
    
    @State private var isRecording: Bool = false
    
    public var body: some View {
        Button(action: { isRecording.toggle() }) {
            Text(isRecording ? "Press keys..." : combo.displayString)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(isRecording ? .white : FramesTheme.textPrimary)
                .frame(minWidth: 84)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isRecording ? FramesTheme.brandElectric : FramesTheme.pillBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isRecording ? FramesTheme.brandAccent : FramesTheme.pillBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .background(
            HotkeyRecorderRepresentable(isRecording: $isRecording, onComboRecorded: { newCombo in
                isRecording = false
                onChanged(newCombo)
            })
        )
    }
}

// MARK: - 3. Support Section (New Illustration, Warm Message, Button, Bottom Text Actions)
public struct SupportSettingsSection: View {
    private var illustrationImage: NSImage? {
        if let bundleUrl = Bundle.main.url(forResource: "support_illustration", withExtension: "png"),
           let img = NSImage(contentsOf: bundleUrl) {
            return img
        }
        let fallbackPath = "/Users/oats/Documents/Frames 2/Resources/support_illustration.png"
        return NSImage(contentsOfFile: fallbackPath)
    }
    
    public var body: some View {
        VStack(spacing: 14) {
            // New Support Illustration Image (No heavy container box)
            if let nsImage = illustrationImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            
            // Warm Support Message
            VStack(spacing: 3) {
                Text("Every coffee makes my mom a little prouder of me. ❤️")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(FramesTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Frames is completely free and open-source.")
                    .font(.system(size: 11))
                    .foregroundColor(FramesTheme.textMuted)
            }
            
            // Primary Support Action Button
            Button(action: {
                if let url = URL(string: "https://buymeacoffee.com/karan01") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Buy Me a Coffee")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(FramesTheme.brandElectric)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 2)
            
            // Bottom Text-Style Actions: Report a Problem & Star on GitHub side by side
            HStack(spacing: 20) {
                Button(action: {
                    FeedbackManager.shared.openProblemReportEmail()
                }) {
                    Text("Report a Problem")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(FramesTheme.textSecondary)
                }
                .buttonStyle(.plain)
                
                Text("•")
                    .foregroundColor(FramesTheme.textMuted)
                
                Button(action: {
                    if let url = URL(string: "https://github.com/karansingh-ux/Frames") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Star on GitHub")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(FramesTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
    }
}

// MARK: - Hotkey Recorder Representable
public struct HotkeyRecorderRepresentable: NSViewRepresentable {
    @Binding var isRecording: Bool
    var onComboRecorded: (KeyCombo) -> Void
    
    public func makeNSView(context: Context) -> KeyRecorderNSView {
        let view = KeyRecorderNSView()
        view.onCombo = onComboRecorded
        return view
    }
    
    public func updateNSView(_ nsView: KeyRecorderNSView, context: Context) {
        nsView.isRecording = isRecording
        if isRecording {
            nsView.window?.makeFirstResponder(nsView)
        }
    }
}

public final class KeyRecorderNSView: NSView {
    var isRecording: Bool = false
    var onCombo: ((KeyCombo) -> Void)?
    
    public override var acceptsFirstResponder: Bool { true }
    
    public override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }
        
        let modifiers = event.modifierFlags.intersection([.command, .option, .shift, .control])
        if !modifiers.isEmpty {
            let combo = KeyCombo(keyCode: event.keyCode, modifiers: modifiers)
            onCombo?(combo)
        }
    }
}
