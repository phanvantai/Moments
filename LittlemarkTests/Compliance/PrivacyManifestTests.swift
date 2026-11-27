import Testing
import Foundation
@testable import Littlemark

/// The app's PrivacyInfo.xcprivacy must ship in the bundle and match the App Privacy answers
/// ("Data Not Collected": moments never leave the device).
@Suite("Privacy manifest")
struct PrivacyManifestTests {
    private let manifest: [String: Any]

    init() throws {
        let url = try #require(Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"))
        let data = try Data(contentsOf: url)
        manifest = try #require(
            try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        )
    }

    @Test("Declares no tracking")
    func noTracking() {
        #expect(manifest["NSPrivacyTracking"] as? Bool == false)
        #expect((manifest["NSPrivacyTrackingDomains"] as? [String])?.isEmpty == true)
    }

    @Test("Declares no collected data")
    func noCollectedData() {
        #expect((manifest["NSPrivacyCollectedDataTypes"] as? [Any])?.isEmpty == true)
    }

    @Test("Declares the UserDefaults reason")
    func userDefaultsReason() {
        let apis = manifest["NSPrivacyAccessedAPITypes"] as? [[String: Any]] ?? []
        let userDefaults = apis.first { $0["NSPrivacyAccessedAPIType"] as? String == "NSPrivacyAccessedAPICategoryUserDefaults" }
        #expect((userDefaults?["NSPrivacyAccessedAPITypeReasons"] as? [String]) == ["CA92.1"])
    }
}
