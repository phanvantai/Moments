import Foundation

struct Moment: Equatable, Hashable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    let createdAt: Date
    var updatedAt: Date
    var title: String?
    var text: String?
    var mediaItems: [MediaItem]
    var voiceNote: VoiceNote?
    var location: Location?
    var categories: [MomentCategory]
    var tags: [String]
    var isFavorite: Bool
    var weather: Weather?
    var visibility: MomentVisibility

    init(
        id: UUID = UUID(),
        userId: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        title: String? = nil,
        text: String? = nil,
        mediaItems: [MediaItem] = [],
        voiceNote: VoiceNote? = nil,
        location: Location? = nil,
        categories: [MomentCategory] = [],
        tags: [String] = [],
        isFavorite: Bool = false,
        weather: Weather? = nil,
        visibility: MomentVisibility = .private
    ) {
        self.id = id
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.text = text
        self.mediaItems = mediaItems
        self.voiceNote = voiceNote
        self.location = location
        self.categories = categories
        self.tags = tags
        self.isFavorite = isFavorite
        self.weather = weather
        self.visibility = visibility
    }

    var hasMedia: Bool {
        !mediaItems.isEmpty || voiceNote != nil
    }
}
