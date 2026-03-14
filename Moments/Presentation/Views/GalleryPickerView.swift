import SwiftUI
import PhotosUI

struct GalleryPickerView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isLoading = false

    var onMediaSelected: ([GalleryMediaResult]) -> Void
    var onDismiss: () -> Void

    var body: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 20,
            matching: .any(of: [.images, .videos]),
            photoLibrary: .shared()
        ) {
            Label(String(localized: "gallery.picker.label"), systemImage: "photo.on.rectangle.angled")
        }
        .photosPickerStyle(.inline)
        .photosPickerDisabledCapabilities(.selectionActions)
        .onChange(of: selectedItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            Task {
                isLoading = true
                var results: [GalleryMediaResult] = []
                for item in newItems {
                    if let result = await loadMediaItem(item) {
                        results.append(result)
                    }
                }
                isLoading = false
                if !results.isEmpty {
                    onMediaSelected(results)
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView(String(localized: "loading.media"))
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func loadMediaItem(_ item: PhotosPickerItem) async -> GalleryMediaResult? {
        // Try loading as image first
        if let data = try? await item.loadTransferable(type: Data.self) {
            if item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                return GalleryMediaResult(data: data, type: .video)
            } else {
                return GalleryMediaResult(data: data, type: .photo)
            }
        }
        return nil
    }
}


