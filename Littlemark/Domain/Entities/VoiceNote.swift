import Foundation

struct VoiceNote: Equatable, Hashable, Sendable {
    let filePath: String
    let duration: TimeInterval
    let transcript: String?

    init(filePath: String, duration: TimeInterval, transcript: String? = nil) {
        self.filePath = filePath
        self.duration = duration
        self.transcript = transcript
    }
}
