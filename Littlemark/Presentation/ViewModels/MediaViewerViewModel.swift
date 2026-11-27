import Foundation

@Observable
@MainActor
final class MediaViewerViewModel {
    let mediaItems: [MediaItem]
    let audioSessionManager: AudioSessionManaging
    var currentPage: Int = 0

    init(mediaItems: [MediaItem], audioSessionManager: AudioSessionManaging = AudioSessionManager.shared) {
        self.mediaItems = mediaItems
        self.audioSessionManager = audioSessionManager
    }

    var showPagerDots: Bool {
        mediaItems.count > 1
    }

    var pageCount: Int {
        mediaItems.count
    }

    func mediaFileURL(for item: MediaItem) -> URL {
        MomentDisplayHelper.mediaFileURL(item.filePath)
    }

    func mediaItem(at index: Int) -> MediaItem? {
        guard index >= 0, index < mediaItems.count else { return nil }
        return mediaItems[index]
    }
}
