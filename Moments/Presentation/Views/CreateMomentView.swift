import SwiftUI
import PhotosUI

struct CreateMomentView: View {
    @Bindable var viewModel: CreateMomentViewModel
    @State private var currentStep: CreateMomentStep = .captureMenu
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isLoadingPhotos = false

    var onDismiss: () -> Void
    var onSaved: () -> Void

    var body: some View {
        ZStack {
            switch currentStep {
            case .captureMenu:
                captureMenuContent

            case .camera:
                CameraView(
                    onPhotoCaptured: { data in
                        handlePhotoCaptured(data)
                    },
                    onVideoCaptured: { url in
                        handleVideoCaptured(url)
                    },
                    onDismiss: { currentStep = .captureMenu }
                )

            case .voice:
                VoiceRecorderView(
                    onRecordingComplete: { url, duration, transcript in
                        handleVoiceRecorded(url: url, duration: duration, transcript: transcript)
                    },
                    onDismiss: { currentStep = .captureMenu }
                )

            case .gallery:
                galleryContent

            case .review:
                ReviewMomentView(
                    viewModel: viewModel,
                    onAddMoreMedia: { currentStep = .captureMenu },
                    onDismiss: onDismiss
                )
            }
        }
        .onChange(of: viewModel.isSaved) { _, saved in
            if saved {
                onSaved()
            }
        }
        .task {
            await viewModel.refreshPermissions()
        }
    }

    // MARK: - Capture Menu

    private var captureMenuContent: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack {
                Spacer()
                CaptureMenuView(
                    isCameraAvailable: viewModel.isCameraAvailable,
                    isVoiceAvailable: viewModel.isVoiceAvailable,
                    isGalleryAvailable: viewModel.isGalleryAvailable,
                    onCameraTap: {
                        Task {
                            let status = await viewModel.requestPermission(.camera)
                            if status == .authorized {
                                currentStep = .camera
                            }
                            await viewModel.refreshPermissions()
                        }
                    },
                    onVoiceTap: {
                        Task {
                            let status = await viewModel.requestPermission(.microphone)
                            if status == .authorized {
                                // Also request speech recognition
                                _ = await viewModel.requestPermission(.speechRecognition)
                                currentStep = .voice
                            }
                            await viewModel.refreshPermissions()
                        }
                    },
                    onGalleryTap: {
                        Task {
                            let status = await viewModel.requestPermission(.photoLibrary)
                            if status == .authorized {
                                currentStep = .gallery
                            }
                            await viewModel.refreshPermissions()
                        }
                    },
                    onDismiss: onDismiss
                )
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Gallery

    private var galleryContent: some View {
        NavigationStack {
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 20,
                matching: .any(of: [.images, .videos]),
                photoLibrary: .shared()
            ) {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Tap to select photos & videos")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .photosPickerStyle(.inline)
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        currentStep = viewModel.capturedMediaItems.isEmpty ? .captureMenu : .review
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if !selectedPhotos.isEmpty {
                        Button("Done") {
                            Task { await loadSelectedPhotos() }
                        }
                        .disabled(isLoadingPhotos)
                    }
                }
            }
            .overlay {
                if isLoadingPhotos {
                    ProgressView("Loading media...")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Media Handlers

    private func handlePhotoCaptured(_ data: Data) {
        Task {
            await viewModel.savePhoto(data: data)
            currentStep = .review
        }
    }

    private func handleVideoCaptured(_ url: URL) {
        Task {
            if let data = try? Data(contentsOf: url) {
                await viewModel.saveVideo(data: data)
            }
            currentStep = .review
        }
    }

    private func handleVoiceRecorded(url: URL, duration: TimeInterval, transcript: String?) {
        Task {
            if let data = try? Data(contentsOf: url) {
                await viewModel.saveVoiceRecording(data: data, duration: duration, transcript: transcript)
            }
            currentStep = .review
        }
    }

    private func loadSelectedPhotos() async {
        isLoadingPhotos = true
        for item in selectedPhotos {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let isVideo = item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) })
                await viewModel.saveGalleryItem(data: data, isVideo: isVideo)
            }
        }
        selectedPhotos = []
        isLoadingPhotos = false
        currentStep = .review
    }
}
