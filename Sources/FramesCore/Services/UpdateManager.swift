import Foundation
import AppKit

public final class UpdateManager {
    public static let shared = UpdateManager()
    
    public static let currentVersion = "1.0.0"
    public static let gitHubRepo = "karansingh-ux/Frames"
    
    private init() {}
    
    private struct GitHubRelease: Decodable {
        let tagName: String
        let htmlUrl: String
        let name: String?
        let body: String?
        
        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
            case htmlUrl = "html_url"
            case name
            case body
        }
    }
    
    public func checkForUpdates(userInitiated: Bool = true) {
        guard let url = URL(string: "https://api.github.com/repos/\(UpdateManager.gitHubRepo)/releases/latest") else {
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: 10.0)
        request.setValue("FramesApp/\(UpdateManager.currentVersion)", forHTTPHeaderField: "User-Agent")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    if userInitiated {
                        self.showErrorAlert(message: "Unable to check for updates. Please check your internet connection.")
                    }
                    NSLog("[Frames] Update check failed: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data,
                      let release = try? JSONDecoder().decode(GitHubRelease.self, from: data) else {
                    if userInitiated {
                        self.showUpToDateAlert()
                    }
                    return
                }
                
                let latestVersion = release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV "))
                let current = UpdateManager.currentVersion.trimmingCharacters(in: CharacterSet(charactersIn: "vV "))
                
                if latestVersion.compare(current, options: .numeric) == .orderedDescending {
                    self.showNewVersionAlert(release: release)
                } else {
                    if userInitiated {
                        self.showUpToDateAlert()
                    }
                }
            }
        }.resume()
    }
    
    private func showNewVersionAlert(release: GitHubRelease) {
        let alert = NSAlert()
        alert.messageText = "A new version of Frames is available!"
        alert.informativeText = "Frames \(release.tagName) is now available (you are currently using v\(UpdateManager.currentVersion)).\n\nWould you like to open GitHub to download the update?"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Download Update")
        alert.addButton(withTitle: "Later")
        
        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let downloadURL = URL(string: release.htmlUrl) {
                NSWorkspace.shared.open(downloadURL)
            }
        }
    }
    
    private func showUpToDateAlert() {
        let alert = NSAlert()
        alert.messageText = "You're up to date!"
        alert.informativeText = "Frames v\(UpdateManager.currentVersion) is currently the latest version."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
    
    private func showErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Update Check"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}
