import Foundation

enum MediaType: String, Equatable, Hashable, Sendable {
    case photo
    case video
}

struct MediaItem: Equatable, Hashable, Identifiable, Sendable {
    let id: UUID
    let momentId: UUID
    let type: MediaType
    let filePath: String
    let thumbnailPath: String?
    let duration: TimeInterval?
    let width: Int
    let height: Int
    let sortOrder: Int

    init(
        id: UUID = UUID(),
        momentId: UUID,
        type: MediaType,
        filePath: String,
        thumbnailPath: String? = nil,
        duration: TimeInterval? = nil,
        width: Int,
        height: Int,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.momentId = momentId
        self.type = type
        self.filePath = filePath
        self.thumbnailPath = thumbnailPath
        self.duration = duration
        self.width = width
        self.height = height
        self.sortOrder = sortOrder
    }
}
