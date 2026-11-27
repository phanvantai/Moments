import Foundation
import Speech

/// Voice notes are transcribed only on device, in the app's language.
/// When the language has no on-device model, the note is saved without a transcript,
/// so audio never leaves the phone.
enum SpeechRecognitionPolicy {
    static func locale(for language: AppLanguage) -> Locale {
        switch language {
        case .english: Locale(identifier: "en-US")
        case .vietnamese: Locale(identifier: "vi-VN")
        case .japanese: Locale(identifier: "ja-JP")
        }
    }

    static func makeRequest(supportsOnDeviceRecognition: Bool) -> SFSpeechAudioBufferRecognitionRequest? {
        guard supportsOnDeviceRecognition else { return nil }
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = true
        return request
    }
}
