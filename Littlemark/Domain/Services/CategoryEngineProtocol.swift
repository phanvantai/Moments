import Foundation

struct CategorySuggestion: Equatable, Sendable {
    let key: String
    let confidence: Double
}

protocol CategoryEngineProtocol: Sendable {
    func suggest(
        text: String?,
        voiceTranscript: String?,
        imageData: [Data]?,
        location: Location?
    ) async -> [String]
}
