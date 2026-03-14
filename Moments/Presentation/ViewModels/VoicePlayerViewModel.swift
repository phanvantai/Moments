import Foundation
import AVFoundation

protocol AudioPlayerProtocol: AnyObject, Sendable {
    var currentTime: TimeInterval { get set }
    var isPlaying: Bool { get }
    func play() -> Bool
    func pause()
    func stop()
}

extension AVAudioPlayer: @retroactive AudioPlayerProtocol {}

@Observable
@MainActor
final class VoicePlayerViewModel {
    let voiceNote: VoiceNote
    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 0

    private var audioPlayer: AudioPlayerProtocol?
    private var timer: Timer?
    private let fileManager: FileManager

    var currentTimeFormatted: String {
        DurationFormatter.shortFormat(currentTime)
    }

    var totalDurationFormatted: String {
        DurationFormatter.shortFormat(voiceNote.duration)
    }

    var progress: Double {
        voiceNote.duration > 0 ? currentTime / voiceNote.duration : 0
    }

    var hasTranscript: Bool {
        guard let transcript = voiceNote.transcript else { return false }
        return !transcript.isEmpty
    }

    var transcript: String? {
        voiceNote.transcript
    }

    var duration: TimeInterval {
        voiceNote.duration
    }

    init(voiceNote: VoiceNote, fileManager: FileManager = .default) {
        self.voiceNote = voiceNote
        self.fileManager = fileManager
    }

    func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }

    func startPlayback() {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(voiceNote.filePath)

        guard fileManager.fileExists(atPath: fileURL.path) else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.currentTime = currentTime
            _ = player.play()
            audioPlayer = player
            isPlaying = true
            startTimer()
        } catch {
            // Playback failed
        }
    }

    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        stopTimer()
    }

    func setAudioPlayer(_ player: AudioPlayerProtocol) {
        audioPlayer = player
    }

    func updateCurrentTime() {
        if let player = audioPlayer {
            currentTime = player.currentTime
            if !player.isPlaying {
                isPlaying = false
                currentTime = 0
                stopTimer()
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateCurrentTime()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
