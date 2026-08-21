import SwiftUI
import AppKit

public struct SettingsView: View {
    @ObservedObject var prefs = AppPreferences.shared
    @ObservedObject var permissions = PermissionsManager.shared
    @State private var selectedTab: SettingsTab = .hotkeys
    
    public enum SettingsTab: String, CaseIterable, Identifiable {
        case hotkeys = "Hotkeys"
        case general = "General"
        case support = "Support"
        
        public var id: String { rawValue }
        
        public var iconName: String {
            switch self {
            case .hotkeys: return "keyboard"
            case .general: return "gearshape"
            case .support: return "heart"
            }
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Segmented Picker
            Picker("", selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    Label(tab.rawValue, systemImage: tab.iconName).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // Tab Content
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if selectedTab == .hotkeys {
                        HotkeysSettingsSection()
                    } else if selectedTab == .general {
                        GeneralSettingsSection()
                    } else {
                        SupportSettingsSection()
                    }
                }
                .padding(20)
            }
        }
        .frame(width: 480, height: 440)
    }
}

public struct HotkeysSettingsSection: View {
    @ObservedObject var prefs = AppPreferences.shared
    @State private var conflictMessage: String?
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Global Shortcuts")
                .font(.headline)
            
            HotkeyRow(
                title: "Full-Screen Screenshot",
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
            
            HotkeyRow(
                title: "Area Screenshot",
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
            
            if let conflict = conflictMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text(conflict)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.yellow.opacity(0.15)))
            }
            
            Text("Tip: Click a shortcut button and press your preferred key combination.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

public struct HotkeyRow: View {
    let title: String
    let combo: KeyCombo
    let usageKey: String
    let onChanged: (KeyCombo) -> Void
    
    @State private var isRecording: Bool = false
    
    public var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
            
            Spacer()
            
            Button(action: { isRecording.toggle() }) {
                Text(isRecording ? "Type shortcut..." : combo.displayString)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(isRecording ? .accentColor : .primary)
                    .frame(minWidth: 90)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isRecording ? Color.accentColor : Color.secondary.opacity(0.4), lineWidth: 1)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.secondary.opacity(0.08)))
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
}

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
        VStack(alignment: .leading, spacing: 16) {
            Text("General Preferences")
                .font(.headline)
            
            // 1. Screenshots Folder
            VStack(alignment: .leading, spacing: 6) {
                Text("Screenshots Folder")
                    .font(.system(size: 13, weight: .medium))
                
                HStack(spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.accentColor)
                        Text(currentFolderName)
                            .font(.system(size: 12))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(minWidth: 160, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color(nsColor: .controlBackgroundColor)))
                    
                    Button("Select Folder...") {
                        selectFolder()
                    }
                    .controlSize(.regular)
                }
            }
            
            Divider()
            
            // 2. Save Format
            VStack(alignment: .leading, spacing: 6) {
                Text("Save Format")
                    .font(.system(size: 13, weight: .medium))
                
                Picker("", selection: $prefs.saveFormat) {
                    ForEach(SaveFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 220)
            }
            
            Divider()
            
            // 3. After Screenshot Behavior
            VStack(alignment: .leading, spacing: 6) {
                Text("After Screenshot")
                    .font(.system(size: 13, weight: .medium))
                
                Picker("", selection: $prefs.afterScreenshot) {
                    ForEach(AfterScreenshotAction.allCases) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 260)
            }
            
            Divider()
            
            // 4. Preview Duration
            VStack(alignment: .leading, spacing: 6) {
                Text("Preview Duration")
                    .font(.system(size: 13, weight: .medium))
                
                Picker("", selection: $prefs.previewDuration) {
                    ForEach(PreviewDuration.allCases) { duration in
                        Text(duration.displayString).tag(duration)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 260)
            }
            
            Divider()
            
            // 5. Sound Effects Toggle
            Toggle("Play shutter sound on capture", isOn: Binding(
                get: { prefs.playSoundOnCapture },
                set: { prefs.playSoundOnCapture = $0 }
            ))
            
            Divider()
            
            // 6. Launch at Startup
            Toggle("Launch Frames at Startup", isOn: Binding(
                get: { prefs.launchAtLogin },
                set: { newValue in
                    prefs.launchAtLogin = newValue
                    LaunchAtLoginManager.shared.setEnabled(newValue)
                }
            ))
            
            Divider()
            
            // System Permissions Status
            VStack(alignment: .leading, spacing: 10) {
                Text("System Permissions")
                    .font(.system(size: 13, weight: .medium))
                
                // Screen Recording
                HStack {
                    Image(systemName: permissions.hasScreenCapturePermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(permissions.hasScreenCapturePermission ? .green : .red)
                    Text("Screen Recording: \(permissions.hasScreenCapturePermission ? "Granted" : "Required")")
                        .font(.system(size: 12))
                    
                    Spacer()
                    
                    if !permissions.hasScreenCapturePermission {
                        Button("Grant Permission") {
                            permissions.requestScreenCapturePermission()
                            permissions.openScreenCaptureSettings()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
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

public struct SupportSettingsSection: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Support & Updates")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Buy Me a Coffee
                HStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Buy Me a Coffee")
                            .font(.system(size: 13, weight: .semibold))
                        
                        Text("Every coffee makes my mom a little prouder of me. ❤️")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let url = URL(string: "https://buymeacoffee.com") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Support")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                
                // Report a Problem
                HStack(spacing: 12) {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Report a Problem")
                            .font(.system(size: 13, weight: .semibold))
                        
                        Text("Found a bug or issue? Send a direct problem report.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Report Issue") {
                        FeedbackManager.shared.openProblemReportEmail()
                    }
                    .controlSize(.regular)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                
                // Check for Updates
                HStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Frames v1.0.0")
                            .font(.system(size: 13, weight: .semibold))
                        
                        Text("Check if a newer version of Frames is available.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Check for Updates") {
                        UpdateManager.shared.checkForUpdates(userInitiated: true)
                    }
                    .controlSize(.regular)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
            }
        }
    }
}
