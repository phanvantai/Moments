import Testing
import Foundation
import Speech
@testable import Littlemark

@MainActor
struct SpeechRecognitionPolicyTests {

    // MARK: - Locale

    @Test(arguments: [
        (AppLanguage.english, "en-US"),
        (AppLanguage.vietnamese, "vi-VN"),
        (AppLanguage.japanese, "ja-JP"),
    ])
    func test_locale_followsAppLanguage(language: AppLanguage, expected: String) {
        let locale = SpeechRecognitionPolicy.locale(for: language)

        #expect(locale.identifier == expected)
    }

    // MARK: - Request

    @Test func test_makeRequest_onDeviceSupported_requiresOnDeviceRecognition() throws {
        let request = try #require(SpeechRecognitionPolicy.makeRequest(supportsOnDeviceRecognition: true))

        #expect(request.requiresOnDeviceRecognition)
        #expect(request.shouldReportPartialResults)
    }

    @Test func test_makeRequest_onDeviceUnsupported_returnsNil() {
        let request = SpeechRecognitionPolicy.makeRequest(supportsOnDeviceRecognition: false)

        #expect(request == nil)
    }
}
