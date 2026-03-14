import Testing
import Foundation
@testable import Moments

struct VoicePlayerViewTests {

    @Test func test_voiceNote_withTranscript_hasTranscript() {
        let voiceNote = VoiceNote(filePath: "test.m4a", duration: 10.0, transcript: "Hello world")

        #expect(voiceNote.transcript == "Hello world")
        #expect(!voiceNote.transcript!.isEmpty)
    }

    @Test func test_voiceNote_withoutTranscript_transcriptIsNil() {
        let voiceNote = VoiceNote(filePath: "test.m4a", duration: 5.0, transcript: nil)

        #expect(voiceNote.transcript == nil)
    }

    @Test func test_voiceNote_duration_isCorrect() {
        let voiceNote = VoiceNote(filePath: "test.m4a", duration: 125.5, transcript: nil)

        #expect(voiceNote.duration == 125.5)
    }

    @Test func test_voiceNote_durationFormatting() {
        let formatted = DurationFormatter.shortFormat(125)

        #expect(formatted == "2:05")
    }

    @Test func test_voiceNote_paddedDurationFormatting() {
        let formatted = DurationFormatter.paddedFormat(125)

        #expect(formatted == "02:05")
    }
}
