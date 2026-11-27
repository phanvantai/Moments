import AVFoundation

/// Protocol for audio session management, enabling dependency injection and testing.
protocol AudioSessionManaging: Sendable {
    func configureForPlayback()
    func configureForRecording()
    func deactivate()
}

/// Centralized manager for AVAudioSession configuration.
final class AudioSessionManager: AudioSessionManaging {
    static let shared = AudioSessionManager()

    private init() {}

    /// Configure audio session for playback (voice notes, video).
    /// Uses `.playback` category to ensure sound plays even when the silent switch is on.
    func configureForPlayback() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            // Audio session configuration failed
        }
    }

    /// Configure audio session for recording (voice recorder).
    /// Uses `.playAndRecord` with `.defaultToSpeaker` so the user can hear playback during recording.
    func configureForRecording() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            // Audio session configuration failed
        }
    }

    /// Deactivate the audio session, notifying other apps they can resume audio.
    func deactivate() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
