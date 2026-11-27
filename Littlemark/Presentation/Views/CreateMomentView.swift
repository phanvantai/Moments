import SwiftUI
import os
import PhotosUI
import UIKit
import UniformTypeIdentifiers

struct CreateMomentView: View {
    @Bindable var viewModel: CreateMomentViewModel
    @State private var currentStep: CreateMomentStep?
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isLoadingPhotos = false

    var onDismiss: () -> Void
    var onSaved: () -> Void

    var body: some View {
        ZStack {
            switch currentStep ?? viewModel.initialStep {
            case .camera:
                CameraView(
                    onPhotoCaptured: { data in
                        handlePhotoCaptured(data)
                    },
                    onVideoCaptured: { url in
                        handleVideoCaptured(url)
                    },
                    onDismiss: {
                        discardAndDismiss()
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))

            case .voice:
                VoiceRecorderView(
                    onRecordingComplete: { url, duration, transcript in
                        handleVoiceRecorded(url: url, duration: duration, transcript: transcript)
                    },
                    onDismiss: {
                        discardAndDismiss()
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))

            case .gallery:
                galleryContent
                    .transition(.move(edge: .trailing).combined(with: .opacity))

            case .review:
                ReviewMomentView(
                    viewModel: viewModel,
                    onDismiss: discardAndDismiss
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

    // MARK: - Gallery

    @State private var showPhotoPicker = false

    private var galleryContent: some View {
        VStack(spacing: 16) {
            if isLoadingPhotos {
                Spacer()
                ProgressView(String(localized: "loading.media", bundle: LanguageManager.shared.bundle))
                    .font(.system(.body, design: .rounded))
                Spacer()
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotos,
            maxSelectionCount: 20,
            matching: .any(of: [.images, .videos]),
            photoLibrary: .shared()
        )
        .onChange(of: selectedPhotos) { _, newValue in
            guard !newValue.isEmpty else { return }
            Task { await loadSelectedPhotos() }
        }
        .onChange(of: showPhotoPicker) { _, isShowing in
            if !isShowing && selectedPhotos.isEmpty && !isLoadingPhotos {
                discardAndDismiss()
            }
        }
        .onAppear {
            showPhotoPicker = true
        }
    }

    // MARK: - Media Handlers

    /// Leaving without saving deletes the files already written for this draft.
    private func discardAndDismiss() {
        let viewModel = viewModel
        Task { await viewModel.discardDraft() }
        onDismiss()
    }

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
            await viewModel.saveVideo(fileURL: url)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentStep = .review
            }
        }
    }

    private func handleVoiceRecorded(url: URL, duration: TimeInterval, transcript: String?) {
        Task {
            await viewModel.saveVoiceRecording(fileURL: url, duration: duration, transcript: transcript)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentStep = .review
            }
        }
    }

    private func loadSelectedPhotos() async {
        isLoadingPhotos = true
        for item in selectedPhotos {
            let isVideo = item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) })
            do {
                if isVideo {
                    if let movie = try await item.loadTransferable(type: TransferableMovie.self) {
                        await viewModel.saveVideo(fileURL: movie.url)
                    }
                } else if let image = try await item.loadTransferable(type: TransferableImage.self) {
                    await viewModel.savePhoto(data: image.data)
                }
            } catch {
                Self.logger.error("Could not load picked item: \(error.localizedDescription, privacy: .public)")
            }
        }
        selectedPhotos = []
        isLoadingPhotos = false
        currentStep = .review
    }

    private static let logger = Logger(subsystem: "com.randomtech.littlemark", category: "Gallery")
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
