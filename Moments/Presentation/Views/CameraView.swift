import SwiftUI
import AVFoundation

struct CameraView: View {
    @State private var capturedImage: UIImage?
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
                CameraControlsView(isRecordingVideo: $isRecordingVideo)
                    .padding(.bottom, 40)
            }
        }
        .alert(String(localized: "camera.error"), isPresented: $showError) {
            Button(String(localized: "ok"), role: .cancel) { onDismiss() }
        } message: {
            Text(errorText)
        }
    }
}

// MARK: - Camera Controls

private struct CameraControlsView: View {
    @Binding var isRecordingVideo: Bool

    var body: some View {
        HStack(spacing: 60) {
            // Photo capture button
            Button {
                // Photo capture is handled via notification
                NotificationCenter.default.post(name: .capturePhoto, object: nil)
            } label: {
                Circle()
                    .fill(.white)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.5), lineWidth: 4)
                            .frame(width: 80, height: 80)
                    )
            }

            // Video record button
            Button {
                isRecordingVideo.toggle()
                if isRecordingVideo {
                    NotificationCenter.default.post(name: .startVideoRecording, object: nil)
                } else {
                    NotificationCenter.default.post(name: .stopVideoRecording, object: nil)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(isRecordingVideo ? .red : .red.opacity(0.7))
                        .frame(width: isRecordingVideo ? 36 : 72, height: isRecordingVideo ? 36 : 72)
                        .animation(.easeInOut(duration: 0.2), value: isRecordingVideo)

                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: 4)
                        .frame(width: 80, height: 80)
                }
            }
        }
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
            onError?(String(localized: "camera.access.error"))
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
            onError?(String(localized: "photo.process.error"))
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
