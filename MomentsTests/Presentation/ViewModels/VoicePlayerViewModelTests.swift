import Testing
import Foundation
@testable import Moments

// MARK: - Mock Audio Player

final class MockAudioPlayer: AudioPlayerProtocol, @unchecked Sendable {
    var currentTime: TimeInterval = 0
    var isPlaying: Bool = false
    var pauseCallCount = 0
    var stopCallCount = 0

    func play() -> Bool {
        isPlaying = true
        return true
    }

    func pause() {
        pauseCallCount += 1
        isPlaying = false
    }

    func stop() {
        stopCallCount += 1
        isPlaying = false
        currentTime = 0
    }
}

@MainActor
struct VoicePlayerViewModelTests {

    // MARK: - Helpers

    private func makeSUT(
        voiceNote: VoiceNote? = nil
    ) -> (VoicePlayerViewModel, MockAudioSessionManager) {
        let mockSession = MockAudioSessionManager()
        let vm = VoicePlayerViewModel(
            voiceNote: voiceNote ?? MockMomentFactory.makeVoiceNote(),
            audioSessionManager: mockSession
        )
        return (vm, mockSession)
    }

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

    // MARK: - Audio Session on Stop

    @Test func test_stopPlayback_deactivatesAudioSession() {
        let (vm, mockSession) = makeSUT()

        vm.stopPlayback()

        #expect(mockSession.deactivateCallCount == 1)
    }

    @Test func test_stopPlayback_doesNotConfigureForPlayback() {
        let (vm, mockSession) = makeSUT()

        vm.stopPlayback()

        #expect(mockSession.configureForPlaybackCallCount == 0)
    }

    // MARK: - Pause with Mock Player

    @Test func test_pausePlayback_callsPauseOnPlayer() {
        let (vm, _) = makeSUT()
        let mockPlayer = MockAudioPlayer()
        vm.setAudioPlayer(mockPlayer)

        vm.pausePlayback()

        #expect(mockPlayer.pauseCallCount == 1)
    }

    @Test func test_pausePlayback_doesNotDeactivateAudioSession() {
        let (vm, mockSession) = makeSUT()
        let mockPlayer = MockAudioPlayer()
        vm.setAudioPlayer(mockPlayer)

        vm.pausePlayback()

        #expect(mockSession.deactivateCallCount == 0)
    }

    // MARK: - Stop with Mock Player

    @Test func test_stopPlayback_callsStopOnPlayer() {
        let (vm, _) = makeSUT()
        let mockPlayer = MockAudioPlayer()
        vm.setAudioPlayer(mockPlayer)

        vm.stopPlayback()

        #expect(mockPlayer.stopCallCount == 1)
    }

    @Test func test_stopPlayback_resetsCurrentTimeAndState() {
        let (vm, _) = makeSUT()
        let mockPlayer = MockAudioPlayer()
        vm.setAudioPlayer(mockPlayer)

        vm.pausePlayback()
        vm.stopPlayback()

        #expect(vm.currentTime == 0)
        #expect(vm.isPlaying == false)
    }

    // MARK: - Update Current Time

    @Test func test_updateCurrentTime_whenPlayerStopped_resetsState() {
        let (vm, _) = makeSUT()
        let mockPlayer = MockAudioPlayer()
        mockPlayer.isPlaying = false
        mockPlayer.currentTime = 5.0
        vm.setAudioPlayer(mockPlayer)

        vm.updateCurrentTime()

        #expect(vm.isPlaying == false)
        #expect(vm.currentTime == 0)
    }
}
