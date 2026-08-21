import Foundation
import AppKit
import AudioToolbox

public final class SoundManager {
    public static let shared = SoundManager()
    
    private var systemSoundID: SystemSoundID = 0
    private var soundLoaded = false
    private var preloadedNSSound: NSSound?
    
    private init() {
        preloadSound()
    }
    
    private func preloadSound() {
        // Look in app bundle resources first, then fallback to system location
        let soundURL: URL? = Bundle.main.url(forResource: "shutter", withExtension: "aif")
            ?? URL(fileURLWithPath: "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Grab.aif")
        
        guard let url = soundURL, FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &systemSoundID)
        if status == kAudioServicesNoError {
            soundLoaded = true
        }
        
        // Also pre-warm NSSound in memory as backup
        preloadedNSSound = NSSound(contentsOf: url, byReference: true)
    }
    
    public func playShutterSound() {
        guard AppPreferences.shared.playSoundOnCapture else { return }
        
        if soundLoaded && systemSoundID != 0 {
            AudioServicesPlaySystemSound(systemSoundID)
        } else if let nsSound = preloadedNSSound {
            nsSound.stop()
            nsSound.play()
        }
    }
}
