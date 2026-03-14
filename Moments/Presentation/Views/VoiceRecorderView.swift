import SwiftUI
import AVFoundation
import Speech

struct VoiceRecorderView: View {
    @State private var recorder = VoiceRecorderState()
    var onRecordingComplete: (URL, TimeInterval, String?) -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            // Top bar
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                Spacer()
            }
            .padding(.horizontal)

            Spacer()

            // Waveform visualization
            WaveformView(levels: recorder.audioLevels, isRecording: recorder.isRecording)
                .frame(height: 100)
                .padding(.horizontal, 32)
                .accessibilityHidden(true)

            // Timer
            Text(recorder.formattedDuration)
                .font(.system(.largeTitle, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary)

            // Transcript preview
            if let transcript = recorder.transcript, !transcript.isEmpty {
                Text(transcript)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Record button
            Button {
                if recorder.isRecording {
                    recorder.stopRecording()
                    if let url = recorder.recordingURL {
                        onRecordingComplete(url, recorder.duration, recorder.transcript)
                    }
                } else {
                    recorder.startRecording()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(recorder.isRecording ? .red : .red.opacity(0.8))
                        .frame(width: 80, height: 80)
                        .shadow(color: .red.opacity(0.3), radius: recorder.isRecording ? 12 : 4)

                    if recorder.isRecording {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .frame(width: 28, height: 28)
                    } else {
                        Circle()
                            .fill(.white)
                            .frame(width: 28, height: 28)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: recorder.isRecording)
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Waveform View

struct WaveformView: View {
    let levels: [CGFloat]
    let isRecording: Bool
    private let barCount = 40

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                let level = index < levels.count ? levels[index] : 0.05
                RoundedRectangle(cornerRadius: 2)
                    .fill(isRecording ? Color.red.opacity(0.7) : Color.gray.opacity(0.3))
                    .frame(width: 4, height: max(4, level * 80))
                    .animation(.easeOut(duration: 0.1), value: level)
            }
        }
    }
}

// MARK: - Voice Recorder State

@Observable
@MainActor
final class VoiceRecorderState {
    var isRecording = false
    var duration: TimeInterval = 0
    var audioLevels: [CGFloat] = []
    var transcript: String?
    var recordingURL: URL?

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?

    var formattedDuration: String {
        DurationFormatter.paddedFormat(duration)
    }

    func startRecording() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")
        recordingURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            duration = 0

            startTimer()
            startTranscription()
        } catch {
            isRecording = false
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopTimer()
        stopTranscription()

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.isRecording else { return }
                self.duration += 0.1
                self.audioRecorder?.updateMeters()
                let level = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
                let normalizedLevel = AudioLevelNormalizer.normalize(decibels: level)
                AudioLevelNormalizer.appendLevel(normalizedLevel, to: &self.audioLevels)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private nonisolated func startTranscription() {
        Task { @MainActor in
            guard SFSpeechRecognizer.authorizationStatus() == .authorized else { return }

            let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "vi-VN"))
            ?? SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
            guard let speechRecognizer, speechRecognizer.isAvailable else { return }
            self.speechRecognizer = speechRecognizer

            let audioEngine = AVAudioEngine()
            self.audioEngine = audioEngine
            let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            recognitionRequest.shouldReportPartialResults = true
            self.recognitionRequest = recognitionRequest

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }

            do {
                try audioEngine.start()
            } catch {
                return
            }

            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, _ in
                Task { @MainActor [weak self] in
                    if let result {
                        self?.transcript = result.bestTranscription.formattedString
                    }
                }
            }
        }
    }

    private func stopTranscription() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
    }
}
