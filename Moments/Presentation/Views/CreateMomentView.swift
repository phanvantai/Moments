import SwiftUI
import PhotosUI
import UIKit
import UniformTypeIdentifiers

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
                    .transition(.opacity)

            case .camera:
                CameraView(
                    onPhotoCaptured: { data in
                        handlePhotoCaptured(data)
                    },
                    onVideoCaptured: { url in
                        handleVideoCaptured(url)
                    },
                    onDismiss: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep = .captureMenu
                        }
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))

            case .voice:
                VoiceRecorderView(
                    onRecordingComplete: { url, duration, transcript in
                        handleVoiceRecorded(url: url, duration: duration, transcript: transcript)
                    },
                    onDismiss: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep = .captureMenu
                        }
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))

            case .gallery:
                galleryContent
                    .transition(.move(edge: .trailing).combined(with: .opacity))

            case .review:
                ReviewMomentView(
                    viewModel: viewModel,
                    onAddMoreMedia: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep = .captureMenu
                        }
                    },
                    onDismiss: onDismiss
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentStep)
        .onChange(of: viewModel.isSaved) { _, saved in
            if saved {
                HapticManager.saveSuccess()
                onSaved()
            }
        }
        .task {
            await viewModel.refreshPermissions()
        }
    }

    @State private var permissionDeniedType: String?

    // MARK: - Capture Menu

    private var captureMenuContent: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack {
                Spacer()

                if let denied = permissionDeniedType {
                    permissionDeniedBanner(for: denied)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                CaptureMenuView(
                    isCameraAvailable: viewModel.isCameraAvailable,
                    isVoiceAvailable: viewModel.isVoiceAvailable,
                    isGalleryAvailable: viewModel.isGalleryAvailable,
                    onCameraTap: {
                        Task {
                            let status = await viewModel.requestPermission(.camera)
                            if status == .authorized {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    currentStep = .camera
                                }
                            } else if status == .denied {
                                withAnimation { permissionDeniedType = "Camera" }
                            }
                            await viewModel.refreshPermissions()
                        }
                    },
                    onVoiceTap: {
                        Task {
                            let status = await viewModel.requestPermission(.microphone)
                            if status == .authorized {
                                _ = await viewModel.requestPermission(.speechRecognition)
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    currentStep = .voice
                                }
                            } else if status == .denied {
                                withAnimation { permissionDeniedType = "Microphone" }
                            }
                            await viewModel.refreshPermissions()
                        }
                    },
                    onGalleryTap: {
                        Task {
                            let status = await viewModel.requestPermission(.photoLibrary)
                            if status == .authorized {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    currentStep = .gallery
                                }
                            } else if status == .denied {
                                withAnimation { permissionDeniedType = "Photo Library" }
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

    private func permissionDeniedBanner(for type: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "permission.denied \(type)", bundle: LanguageManager.shared.bundle))
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                Text(String(localized: "permission.enable.settings", bundle: LanguageManager.shared.bundle))
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(String(localized: "settings", bundle: LanguageManager.shared.bundle)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(.blue))
            .foregroundStyle(.white)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
    }

    // MARK: - Gallery

    @State private var showPhotoPicker = false

    private var galleryContent: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if isLoadingPhotos {
                    Spacer()
                    ProgressView(String(localized: "loading.media", bundle: LanguageManager.shared.bundle))
                    Spacer()
                } else {
                    Spacer()
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text(String(localized: "gallery.select.prompt", bundle: LanguageManager.shared.bundle))
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(String(localized: "gallery.title", bundle: LanguageManager.shared.bundle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "back", bundle: LanguageManager.shared.bundle)) {
                        currentStep = viewModel.capturedMediaItems.isEmpty ? .captureMenu : .review
                    }
                }
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhotos,
                maxSelectionCount: 20,
                matching: .any(of: [.images, .videos]),
                photoLibrary: .shared()
            )
            .onChange(of: selectedPhotos) { _, newValue in
                guard !newValue.isEmpty else { return }
                print("[Gallery] selection confirmed: \(newValue.count) items")
                Task { await loadSelectedPhotos() }
            }
            .onAppear {
                showPhotoPicker = true
            }
        }
    }

    // MARK: - Media Handlers

    private func handlePhotoCaptured(_ data: Data) {
        Task {
            await viewModel.savePhoto(data: data)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentStep = .review
            }
        }
    }

    private func handleVideoCaptured(_ url: URL) {
        Task {
            if let data = try? Data(contentsOf: url) {
                await viewModel.saveVideo(data: data)
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentStep = .review
            }
        }
    }

    private func handleVoiceRecorded(url: URL, duration: TimeInterval, transcript: String?) {
        Task {
            if let data = try? Data(contentsOf: url) {
                await viewModel.saveVoiceRecording(data: data, duration: duration, transcript: transcript)
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentStep = .review
            }
        }
    }

    private func loadSelectedPhotos() async {
        print("[Gallery] loadSelectedPhotos called, count: \(selectedPhotos.count)")
        isLoadingPhotos = true
        for (index, item) in selectedPhotos.enumerated() {
            let types = item.supportedContentTypes
            print("[Gallery] Item \(index): contentTypes = \(types.map(\.identifier))")
            let isVideo = types.contains(where: { $0.conforms(to: .movie) })
            print("[Gallery] Item \(index): isVideo = \(isVideo)")
            if isVideo {
                do {
                    let movie = try await item.loadTransferable(type: TransferableMovie.self)
                    if let movie {
                        let data = try Data(contentsOf: movie.url)
                        print("[Gallery] Item \(index): video loaded, bytes = \(data.count)")
                        await viewModel.saveGalleryItem(data: data, isVideo: true)
                    } else {
                        print("[Gallery] Item \(index): loadTransferable(TransferableMovie) returned nil")
                    }
                } catch {
                    print("[Gallery] Item \(index): video load error: \(error)")
                }
            } else {
                do {
                    let imageData = try await item.loadTransferable(type: TransferableImage.self)
                    if let imageData {
                        print("[Gallery] Item \(index): image loaded, bytes = \(imageData.data.count)")
                        await viewModel.saveGalleryItem(data: imageData.data, isVideo: false)
                    } else {
                        print("[Gallery] Item \(index): loadTransferable(TransferableImage) returned nil")
                    }
                } catch {
                    print("[Gallery] Item \(index): image load error: \(error)")
                }
            }
        }
        print("[Gallery] Done loading. capturedMediaItems count: \(viewModel.capturedMediaItems.count)")
        selectedPhotos = []
        isLoadingPhotos = false
        currentStep = .review
    }
}

// MARK: - Transferable Types

private struct TransferableImage: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            TransferableImage(data: data)
        }
    }
}

private struct TransferableMovie: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { receivedFile in
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            try FileManager.default.copyItem(at: receivedFile.file, to: tempURL)
            return TransferableMovie(url: tempURL)
        }
    }
}
