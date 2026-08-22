import Foundation
import CryptoKit

// Sparkle AppCast Generator using Apple CryptoKit (Ed25519)
struct AppcastGenerator {
    static func run() {
        let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let keyFile = rootURL.appendingPathComponent("Scripts/sparkle_keys.json")
        let zipURL = rootURL.appendingPathComponent("Export/Frames.zip")
        let appcastOutWebsite = rootURL.appendingPathComponent("website/public/appcast.xml")
        let appcastOutExport = rootURL.appendingPathComponent("Export/appcast.xml")
        
        guard FileManager.default.fileExists(atPath: zipURL.path) else {
            print("❌ Export/Frames.zip not found. Please run ./Scripts/build_app.sh first.")
            exit(1)
        }
        
        guard let keyData = try? Data(contentsOf: keyFile),
              let keyJson = try? JSONSerialization.jsonObject(with: keyData) as? [String: String],
              let privStr = keyJson["private_key"],
              let privBytes = Data(base64Encoded: privStr),
              let privateKey = try? Curve25519.Signing.PrivateKey(rawRepresentation: privBytes) else {
            print("❌ Private key not found in Scripts/sparkle_keys.json")
            exit(1)
        }
        
        guard let zipData = try? Data(contentsOf: zipURL) else {
            print("❌ Failed to read Export/Frames.zip")
            exit(1)
        }
        
        // Sign the zip archive
        guard let signature = try? privateKey.signature(for: zipData) else {
            print("❌ Failed to generate cryptographic Ed25519 signature")
            exit(1)
        }
        let signatureBase64 = signature.base64EncodedString()
        let fileLength = zipData.count
        
        let dateString = ISO8601DateFormatter().string(from: Date())
        let rfc822Formatter = DateFormatter()
        rfc822Formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        rfc822Formatter.locale = Locale(identifier: "en_US_POSIX")
        let pubDate = rfc822Formatter.string(from: Date())
        
        let version = "1.0.0"
        let buildNumber = "1"
        let downloadURL = "https://framesapp.com/downloads/Frames.zip"
        
        let xml = """
        <?xml version="1.0" encoding="utf-8"?>
        <rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
            <channel>
                <title>Frames Changelog</title>
                <link>https://framesapp.com/appcast.xml</link>
                <description>Most recent updates to Frames macOS.</description>
                <language>en</language>
                <item>
                    <title>Frames \(version)</title>
                    <pubDate>\(pubDate)</pubDate>
                    <sparkle:releaseNotesLink>https://framesapp.com/releases/\(version).html</sparkle:releaseNotesLink>
                    <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
                    <enclosure
                        url="\(downloadURL)"
                        sparkle:version="\(buildNumber)"
                        sparkle:shortVersionString="\(version)"
                        length="\(fileLength)"
                        type="application/octet-stream"
                        sparkle:edSignature="\(signatureBase64)" />
                </item>
            </channel>
        </rss>
        """
        
        try? xml.write(to: appcastOutWebsite, atomically: true, encoding: .utf8)
        try? xml.write(to: appcastOutExport, atomically: true, encoding: .utf8)
        
        print("✅ Successfully generated signed appcast.xml:")
        print("   - Length: \(fileLength) bytes")
        print("   - EdSignature: \(signatureBase64)")
        print("   - Synced to: \(appcastOutWebsite.path)")
    }
}

AppcastGenerator.run()
