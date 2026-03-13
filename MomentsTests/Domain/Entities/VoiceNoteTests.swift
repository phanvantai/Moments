import Testing
import Foundation
@testable import Moments

struct VoiceNoteTests {

    @Test func test_init_withTranscript_storesCorrectly() {
        let voiceNote = VoiceNote(
            filePath: "Voice/note.m4a",
            duration: 10.5,
            transcript: "Hello world"
        )

        #expect(voiceNote.filePath == "Voice/note.m4a")
        #expect(voiceNote.duration == 10.5)
        #expect(voiceNote.transcript == "Hello world")
    }

    @Test func test_init_withoutTranscript_transcriptIsNil() {
        let voiceNote = VoiceNote(filePath: "Voice/note.m4a", duration: 5.0)
        #expect(voiceNote.transcript == nil)
    }

    @Test func test_equatable_sameNotes_areEqual() {
        let note1 = VoiceNote(filePath: "a.m4a", duration: 10.0, transcript: "hi")
        let note2 = VoiceNote(filePath: "a.m4a", duration: 10.0, transcript: "hi")
        #expect(note1 == note2)
    }

    @Test func test_equatable_differentNotes_areNotEqual() {
        let note1 = VoiceNote(filePath: "a.m4a", duration: 10.0)
        let note2 = VoiceNote(filePath: "b.m4a", duration: 20.0)
        #expect(note1 != note2)
    }
}
