import Foundation
@testable import Littlemark

final class MockAudioSessionManager: AudioSessionManaging, @unchecked Sendable {
    var configureForPlaybackCallCount = 0
    var configureForRecordingCallCount = 0
    var deactivateCallCount = 0

    func configureForPlayback() {
        configureForPlaybackCallCount += 1
    }

    func configureForRecording() {
        configureForRecordingCallCount += 1
    }

    func deactivate() {
        deactivateCallCount += 1
    }
}
