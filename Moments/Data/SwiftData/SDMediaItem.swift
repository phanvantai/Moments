import Foundation
import SwiftData

@Model
final class SDMediaItem {
    @Attribute(.unique) var id: UUID
    var momentId: UUID
    var type: String
    var filePath: String
    var thumbnailPath: String?
    var duration: Double?
    var width: Int
    var height: Int
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        momentId: UUID,
        type: String,
        filePath: String,
        thumbnailPath: String? = nil,
        duration: Double? = nil,
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
