import Foundation
import AppKit

public final class FeedbackManager {
    public static let shared = FeedbackManager()
    
    public static let supportEmail = "buildbetterwithme@gmail.com"
    public static let appVersion = "1.0.0"
    
    private init() {}
    
    public func openProblemReportEmail() {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        
        #if arch(arm64)
        let arch = "Apple Silicon (arm64)"
        #else
        let arch = "Intel (x86_64)"
        #endif
        
        let subject = "[Frames Problem Report] - v\(FeedbackManager.appVersion)"
        let body = """
        --- Frames Problem Report ---
        App Version: \(FeedbackManager.appVersion)
        macOS Version: \(osVersion)
        Architecture: \(arch)
        
        1. What happened:
        [Please describe the issue here]
        
        2. Steps to reproduce:
        - Step 1:
        - Step 2:
        - Step 3:
        
        3. Expected behavior:
        [What did you expect to happen?]
        -----------------------------
        """
        
        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "mailto:\(FeedbackManager.supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)") else {
            return
        }
        
        NSWorkspace.shared.open(url)
    }
}
