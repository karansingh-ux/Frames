import Foundation

public enum SaveFormat: String, CaseIterable, Identifiable, Codable {
    case auto = "Auto (PNG/JPEG)"
    case png = "PNG"
    case jpeg = "JPEG"
    
    public var id: String { rawValue }
}

public enum AfterScreenshotAction: String, CaseIterable, Identifiable, Codable {
    case show = "Show"
    case copy = "Copy"
    case save = "Save"
    
    public var id: String { rawValue }
}

public enum PreviewDuration: Int, CaseIterable, Identifiable, Codable {
    case sixty = 60
    case ninety = 90
    case oneTwenty = 120
    
    public var id: Int { rawValue }
    
    public var displayString: String {
        return "\(rawValue) sec"
    }
}

public final class AppPreferences: ObservableObject {
    public static let shared = AppPreferences()
    
    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
        static let fullScreenHotkey = "fullScreenHotkey"
        static let areaHotkey = "areaHotkey"
        static let saveDirectoryPath = "saveDirectoryPath"
        static let saveFormat = "saveFormat"
        static let afterScreenshot = "afterScreenshot"
        static let previewDuration = "previewDuration"
        static let playSoundOnCapture = "playSoundOnCapture"
    }
    
    private let defaults = UserDefaults.standard
    
    @Published public var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }
    
    @Published public var saveFormat: SaveFormat {
        didSet { defaults.set(saveFormat.rawValue, forKey: Keys.saveFormat) }
    }
    
    @Published public var afterScreenshot: AfterScreenshotAction {
        didSet { defaults.set(afterScreenshot.rawValue, forKey: Keys.afterScreenshot) }
    }
    
    @Published public var previewDuration: PreviewDuration {
        didSet { defaults.set(previewDuration.rawValue, forKey: Keys.previewDuration) }
    }
    
    @Published public var playSoundOnCapture: Bool {
        didSet { defaults.set(playSoundOnCapture, forKey: Keys.playSoundOnCapture) }
    }
    
    @Published public var fullScreenHotkey: KeyCombo {
        didSet { saveKeyCombo(fullScreenHotkey, forKey: Keys.fullScreenHotkey) }
    }
    
    @Published public var areaHotkey: KeyCombo {
        didSet { saveKeyCombo(areaHotkey, forKey: Keys.areaHotkey) }
    }
    
    @Published public var saveDirectoryPath: String {
        didSet { defaults.set(saveDirectoryPath, forKey: Keys.saveDirectoryPath) }
    }
    
    private init() {
        self.launchAtLogin = defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? true
        
        if let rawFormat = defaults.string(forKey: Keys.saveFormat), let format = SaveFormat(rawValue: rawFormat) {
            self.saveFormat = format
        } else {
            self.saveFormat = .auto
        }
        
        if let rawAction = defaults.string(forKey: Keys.afterScreenshot), let action = AfterScreenshotAction(rawValue: rawAction) {
            self.afterScreenshot = action
        } else {
            self.afterScreenshot = .show
        }
        
        let durationRaw = defaults.integer(forKey: Keys.previewDuration)
        if let dur = PreviewDuration(rawValue: durationRaw) {
            self.previewDuration = dur
        } else {
            self.previewDuration = .sixty
        }
        
        self.playSoundOnCapture = defaults.object(forKey: Keys.playSoundOnCapture) as? Bool ?? true
        
        let defaultDesktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first?.path ?? ("~/Desktop" as NSString).expandingTildeInPath
        self.saveDirectoryPath = defaults.string(forKey: Keys.saveDirectoryPath) ?? defaultDesktop
        
        self.fullScreenHotkey = AppPreferences.loadKeyCombo(forKey: Keys.fullScreenHotkey, fallback: .defaultFullScreen)
        self.areaHotkey = AppPreferences.loadKeyCombo(forKey: Keys.areaHotkey, fallback: .defaultArea)
    }
    
    private func saveKeyCombo(_ combo: KeyCombo, forKey key: String) {
        if let data = try? JSONEncoder().encode(combo) {
            defaults.set(data, forKey: key)
        }
    }
    
    private static func loadKeyCombo(forKey key: String, fallback: KeyCombo) -> KeyCombo {
        guard let data = UserDefaults.standard.data(forKey: key),
              let combo = try? JSONDecoder().decode(KeyCombo.self, from: data) else {
            return fallback
        }
        return combo
    }
}
