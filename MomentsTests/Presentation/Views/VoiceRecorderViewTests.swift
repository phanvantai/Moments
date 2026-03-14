import Testing
import Foundation
@testable import Moments

@MainActor
struct VoiceRecorderViewTests {

    // MARK: - VoiceRecorderState Initial State

    @Test func test_initialState_isNotRecording() {
        let state = VoiceRecorderState()

        #expect(state.isRecording == false)
        #expect(state.duration == 0)
        #expect(state.audioLevels.isEmpty)
        #expect(state.transcript == nil)
        #expect(state.recordingURL == nil)
    }

    // MARK: - Formatted Duration via DurationFormatter

    @Test func test_formattedDuration_zero_returns0000() {
        let state = VoiceRecorderState()

        #expect(state.formattedDuration == "00:00")
    }

    @Test func test_formattedDuration_65seconds_returns0105() {
        let state = VoiceRecorderState()
        state.duration = 65

        #expect(state.formattedDuration == "01:05")
    }

    @Test func test_formattedDuration_30seconds_returns0030() {
        let state = VoiceRecorderState()
        state.duration = 30

        #expect(state.formattedDuration == "00:30")
    }

    @Test func test_formattedDuration_600seconds_returns1000() {
        let state = VoiceRecorderState()
        state.duration = 600

        #expect(state.formattedDuration == "10:00")
    }

    @Test func test_formattedDuration_5seconds_returns0005() {
        let state = VoiceRecorderState()
        state.duration = 5

        #expect(state.formattedDuration == "00:05")
    }

    @Test func test_formattedDuration_90seconds_returns0130() {
        let state = VoiceRecorderState()
        state.duration = 90

        #expect(state.formattedDuration == "01:30")
    }

    // MARK: - State Properties Mutation

    @Test func test_duration_canBeSet() {
        let state = VoiceRecorderState()
        state.duration = 42.5

        #expect(state.duration == 42.5)
    }

    @Test func test_audioLevels_canBeSet() {
        let state = VoiceRecorderState()
        state.audioLevels = [0.1, 0.2, 0.3]

        #expect(state.audioLevels == [0.1, 0.2, 0.3])
    }

    @Test func test_transcript_canBeSet() {
        let state = VoiceRecorderState()
        state.transcript = "Hello world"

        #expect(state.transcript == "Hello world")
    }

    @Test func test_transcript_canBeSetToNil() {
        let state = VoiceRecorderState()
        state.transcript = "Hello"
        state.transcript = nil

        #expect(state.transcript == nil)
    }

    @Test func test_recordingURL_canBeSet() {
        let state = VoiceRecorderState()
        let url = URL(fileURLWithPath: "/tmp/test.m4a")
        state.recordingURL = url

        #expect(state.recordingURL == url)
    }

    @Test func test_isRecording_canBeSet() {
        let state = VoiceRecorderState()
        state.isRecording = true

        #expect(state.isRecording == true)
    }

    // MARK: - Stop Recording (without starting)

    @Test func test_stopRecording_whenNotRecording_setsIsRecordingToFalse() {
        let state = VoiceRecorderState()
        state.stopRecording()

        #expect(state.isRecording == false)
    }

    // MARK: - WaveformView

    @Test func test_waveformView_init_setsProperties() {
        let levels: [CGFloat] = [0.1, 0.5, 0.8]
        let waveform = WaveformView(levels: levels, isRecording: true)

        #expect(waveform.levels == levels)
        #expect(waveform.isRecording == true)
    }

    @Test func test_waveformView_notRecording() {
        let waveform = WaveformView(levels: [], isRecording: false)

        #expect(waveform.isRecording == false)
        #expect(waveform.levels.isEmpty)
    }

    @Test func test_waveformView_manyLevels() {
        let levels: [CGFloat] = (0..<40).map { CGFloat($0) / 40.0 }
        let waveform = WaveformView(levels: levels, isRecording: true)

        #expect(waveform.levels.count == 40)
    }
}
