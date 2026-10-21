import Foundation
@testable import Littlemark

final class MockCategoryEngine: CategoryEngineProtocol, @unchecked Sendable {
    var suggestCallCount = 0
    var lastText: String?
    var lastVoiceTranscript: String?
    var lastImageData: [Data]?
    var lastLocation: Location?
    var categoriesToReturn: [String] = ["daily"]

    func suggest(
        text: String?,
        voiceTranscript: String?,
        imageData: [Data]?,
        location: Location?
    ) async -> [String] {
        suggestCallCount += 1
        lastText = text
        lastVoiceTranscript = voiceTranscript
        lastImageData = imageData
        lastLocation = location
        return categoriesToReturn
    }
}
