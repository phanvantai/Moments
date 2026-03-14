import Testing
import Foundation
@testable import Moments

@MainActor
struct VoicePlayerViewModelTests {

    // MARK: - Initial State

    @Test func test_initial_isNotPlaying() {
        let voiceNote = MockMomentFactory.makeVoiceNote()
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        #expect(vm.isPlaying == false)
    }

    @Test func test_initial_currentTimeIsZero() {
        let voiceNote = MockMomentFactory.makeVoiceNote()
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        #expect(vm.currentTime == 0)
    }

    @Test func test_initial_progressIsZero() {
        let voiceNote = MockMomentFactory.makeVoiceNote()
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        #expect(vm.progress == 0)
    }

    // MARK: - Formatted Time

    @Test func test_currentTimeFormatted_initial() {
        let voiceNote = MockMomentFactory.makeVoiceNote()
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        #expect(vm.currentTimeFormatted == "0:00")
    }

    @Test func test_totalDurationFormatted() {
        let voiceNote = VoiceNote(filePath: "test.m4a", duration: 125, transcript: nil)
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        #expect(vm.totalDurationFormatted == "2:05")
    }

    // MARK: - Transcript

    @Test func test_hasTranscript_withTranscript_returnsTrue() {
        let voiceNote = VoiceNote(filePath: "test.m4a", duration: 10, transcript: "Hello world")
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        #expect(vm.hasTranscript == true)
        #expect(vm.transcript == "Hello world")
    }

    @Test func test_hasTranscript_withEmptyTranscript_returnsFalse() {
        let voiceNote = VoiceNote(filePath: "test.m4a", duration: 10, transcript: "")
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        #expect(vm.hasTranscript == false)
    }

    @Test func test_hasTranscript_withNilTranscript_returnsFalse() {
        let voiceNote = VoiceNote(filePath: "test.m4a", duration: 10, transcript: nil)
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        #expect(vm.hasTranscript == false)
        #expect(vm.transcript == nil)
    }

    // MARK: - Duration

    @Test func test_duration_matchesVoiceNote() {
        let voiceNote = VoiceNote(filePath: "test.m4a", duration: 42.5, transcript: nil)
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        #expect(vm.duration == 42.5)
    }

    // MARK: - Progress

    @Test func test_progress_zeroDuration_returnsZero() {
        let voiceNote = VoiceNote(filePath: "test.m4a", duration: 0, transcript: nil)
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        #expect(vm.progress == 0)
    }

    // MARK: - Stop Playback

    @Test func test_stopPlayback_resetsState() {
        let voiceNote = MockMomentFactory.makeVoiceNote()
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        vm.stopPlayback()

        #expect(vm.isPlaying == false)
        #expect(vm.currentTime == 0)
    }

    // MARK: - Pause Playback

    @Test func test_pausePlayback_setsNotPlaying() {
        let voiceNote = MockMomentFactory.makeVoiceNote()
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        vm.pausePlayback()

        #expect(vm.isPlaying == false)
    }

    // MARK: - Toggle Playback (without real file)

    @Test func test_togglePlayback_whenNotPlaying_attemptsStart() {
        let voiceNote = VoiceNote(filePath: "nonexistent.m4a", duration: 10, transcript: nil)
        let vm = VoicePlayerViewModel(voiceNote: voiceNote)

        // File doesn't exist, so it won't actually play
        vm.togglePlayback()

        // Still not playing because file doesn't exist
        #expect(vm.isPlaying == false)
    }
}
