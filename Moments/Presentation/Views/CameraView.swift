import SwiftUI
import AVFoundation

// MARK: - Capture Mode

private enum CaptureMode: String, CaseIterable {
    case photo
    case video
}

struct CameraView: View {
    @State private var capturedImage: UIImage?
    @State private var captureMode: CaptureMode = .photo
    @State private var isRecordingVideo = false
    @State private var showError = false
    @State private var errorText = ""

    var onPhotoCaptured: (Data) -> Void
    var onVideoCaptured: (URL) -> Void
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            CameraPreviewRepresentable(
                onPhotoCaptured: { data in
                    onPhotoCaptured(data)
                },
                onVideoCaptured: { url in
                    onVideoCaptured(url)
                },
                onError: { message in
                    errorText = message
                    showError = true
                },
                isRecordingVideo: $isRecordingVideo
            )
            .ignoresSafeArea()

            VStack {
                // Top bar
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(.black.opacity(0.5)))
                    }
                    Spacer()
                }
                .padding()

                Spacer()

                // Bottom controls
                CameraControlsView(
                    captureMode: $captureMode,
                    isRecordingVideo: $isRecordingVideo
                )
                .padding(.bottom, 40)
            }
        }
        .alert(String(localized: "camera.error", bundle: LanguageManager.shared.bundle), isPresented: $showError) {
            Button(String(localized: "ok", bundle: LanguageManager.shared.bundle), role: .cancel) { onDismiss() }
        } message: {
            Text(errorText)
        }
    }
}

// MARK: - Camera Controls

private struct CameraControlsView: View {
    @Binding var captureMode: CaptureMode
    @Binding var isRecordingVideo: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Capture button
            Button {
                if captureMode == .photo {
                    NotificationCenter.default.post(name: .capturePhoto, object: nil)
                } else {
                    isRecordingVideo.toggle()
                    if isRecordingVideo {
                        NotificationCenter.default.post(name: .startVideoRecording, object: nil)
                    } else {
                        NotificationCenter.default.post(name: .stopVideoRecording, object: nil)
                    }
                }
            } label: {
                ZStack {
                    if captureMode == .photo {
                        // Photo: white filled circle
                        Circle()
                            .fill(.white)
                            .frame(width: 72, height: 72)
                    } else {
                        // Video: red circle that shrinks to rounded rect when recording
                        RoundedRectangle(cornerRadius: isRecordingVideo ? 8 : 36)
                            .fill(.red)
                            .frame(
                                width: isRecordingVideo ? 36 : 72,
                                height: isRecordingVideo ? 36 : 72
                            )
                    }

                    // Outer ring
                    Circle()
                        .stroke(
                            captureMode == .photo ? .white.opacity(0.5) : .red.opacity(0.5),
                            lineWidth: 4
                        )
                        .frame(width: 80, height: 80)
                }
                .animation(.easeInOut(duration: 0.2), value: isRecordingVideo)
                .animation(.easeInOut(duration: 0.25), value: captureMode)
            }
            .disabled(captureMode == .photo && isRecordingVideo)

            // Mode toggle switch
            CaptureModeSwitcher(captureMode: $captureMode)
                .opacity(isRecordingVideo ? 0.3 : 1.0)
                .allowsHitTesting(!isRecordingVideo)
                .animation(.easeInOut(duration: 0.2), value: isRecordingVideo)
        }
    }
}

// MARK: - Capture Mode Switcher

private struct CaptureModeSwitcher: View {
    @Binding var captureMode: CaptureMode
    @Namespace private var modeNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CaptureMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        captureMode = mode
                    }
                } label: {
                    Text(mode == .photo
                         ? String(localized: "capture.mode.photo", bundle: LanguageManager.shared.bundle)
                         : String(localized: "capture.mode.video", bundle: LanguageManager.shared.bundle))
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(captureMode == mode ? .black : .white.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background {
                            if captureMode == mode {
                                Capsule()
                                    .fill(.white)
                                    .matchedGeometryEffect(id: "modeIndicator", in: modeNamespace)
                            }
                        }
                }
            }
        }
        .padding(3)
        .background(
            Capsule()
                .fill(.white.opacity(0.2))
        )
    }
}

// MARK: - Camera Preview UIViewRepresentable

struct CameraPreviewRepresentable: UIViewControllerRepresentable {
    var onPhotoCaptured: (Data) -> Void
    var onVideoCaptured: (URL) -> Void
    var onError: (String) -> Void
    @Binding var isRecordingVideo: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onPhotoCaptured = onPhotoCaptured
        controller.onVideoCaptured = onVideoCaptured
        controller.onError = onError
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

// MARK: - Camera View Controller

final class CameraViewController: UIViewController {
    var onPhotoCaptured: ((Data) -> Void)?
    var onVideoCaptured: ((URL) -> Void)?
    var onError: ((String) -> Void)?

    private let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var movieOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        observeNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupCamera() {
        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            onError?(String(localized: "camera.access.error", bundle: LanguageManager.shared.bundle))
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        // Add audio input for video recording
        if let microphone = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: microphone),
           captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }

        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        previewLayer = preview

        Task.detached { [captureSession] in
            captureSession.startRunning()
        }
    }

    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(capturePhoto),
            name: .capturePhoto, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(startVideoRecording),
            name: .startVideoRecording, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(stopVideoRecording),
            name: .stopVideoRecording, object: nil
        )
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc private func startVideoRecording() {
        guard !movieOutput.isRecording else { return }
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
    }

    @objc private func stopVideoRecording() {
        guard movieOutput.isRecording else { return }
        movieOutput.stopRecording()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        captureSession.stopRunning()
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            onError?(error.localizedDescription)
            return
        }
        guard let data = photo.fileDataRepresentation() else {
            onError?(String(localized: "photo.process.error", bundle: LanguageManager.shared.bundle))
            return
        }
        onPhotoCaptured?(data)
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error {
            onError?(error.localizedDescription)
            return
        }
        onVideoCaptured?(outputFileURL)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
    static let startVideoRecording = Notification.Name("startVideoRecording")
    static let stopVideoRecording = Notification.Name("stopVideoRecording")
}
