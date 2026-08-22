import Foundation
import AppKit
import Sparkle

public final class UpdateManager: NSObject, SPUUpdaterDelegate {
    public static let shared = UpdateManager()
    
    private var updaterController: SPUStandardUpdaterController?
    
    public override init() {
        super.init()
        // Initialize standard Sparkle updater with automatic background checks
        self.updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
    }
    
    public func checkForUpdates(userInitiated: Bool = true) {
        if let controller = updaterController {
            controller.checkForUpdates(nil)
        } else {
            // Re-instantiate if needed
            self.updaterController = SPUStandardUpdaterController(
                startingUpdater: true,
                updaterDelegate: self,
                userDriverDelegate: nil
            )
            self.updaterController?.checkForUpdates(nil)
        }
    }
    
    // MARK: - Sparkle Delegate Hooks
    
    public func updater(_ updater: SPUUpdater, willScheduleUpdateCheckAfterDelay delay: TimeInterval) {
        NSLog("[Frames Sparkle] Scheduled next update check in \(Int(delay)) seconds.")
    }
    
    public func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        NSLog("[Frames Sparkle] App is up to date.")
    }
}
