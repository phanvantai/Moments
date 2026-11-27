import Testing
import Foundation
@testable import Littlemark

@MainActor
struct AppLinksTests {

    @Test func test_privacyPolicy_english_hasNoLanguageQuery() {
        #expect(AppLinks.privacyPolicy(language: .english).absoluteString == "https://littlemark.taiphanvan.dev/privacy.html")
    }

    @Test(arguments: [(AppLanguage.vietnamese, "vi"), (AppLanguage.japanese, "ja")])
    func test_privacyPolicy_otherLanguages_openInThatLanguage(language: AppLanguage, code: String) {
        #expect(AppLinks.privacyPolicy(language: language).absoluteString == "https://littlemark.taiphanvan.dev/privacy.html?lang=\(code)")
    }

    @Test func test_support_vietnamese_opensSupportPage() {
        #expect(AppLinks.support(language: .vietnamese).absoluteString == "https://littlemark.taiphanvan.dev/support.html?lang=vi")
    }
}
