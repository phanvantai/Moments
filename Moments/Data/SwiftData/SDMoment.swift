import Foundation
import SwiftData

@Model
final class SDMoment {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var createdAt: Date
    var updatedAt: Date
    var title: String?
    var text: String?
    @Relationship(deleteRule: .cascade) var mediaItems: [SDMediaItem]
    var voiceNoteFilePath: String?
    var voiceNoteDuration: Double?
    var voiceNoteTranscript: String?
    var locationLatitude: Double?
    var locationLongitude: Double?
    var locationName: String?
    var locationAddress: String?
    var locationPlaceType: String?
    var categoryKeys: [String]
    var tags: [String]
    var isFavorite: Bool
    var weatherCondition: String?
    var weatherTemperature: Double?
    var weatherIcon: String?
    var visibility: String

    init(
        id: UUID = UUID(),
        userId: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        title: String? = nil,
        text: String? = nil,
        mediaItems: [SDMediaItem] = [],
        voiceNoteFilePath: String? = nil,
        voiceNoteDuration: Double? = nil,
        voiceNoteTranscript: String? = nil,
        locationLatitude: Double? = nil,
        locationLongitude: Double? = nil,
        locationName: String? = nil,
        locationAddress: String? = nil,
        locationPlaceType: String? = nil,
        categoryKeys: [String] = [],
        tags: [String] = [],
        isFavorite: Bool = false,
        weatherCondition: String? = nil,
        weatherTemperature: Double? = nil,
        weatherIcon: String? = nil,
        visibility: String = "private"
    ) {
        self.id = id
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.text = text
        self.mediaItems = mediaItems
        self.voiceNoteFilePath = voiceNoteFilePath
        self.voiceNoteDuration = voiceNoteDuration
        self.voiceNoteTranscript = voiceNoteTranscript
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.locationPlaceType = locationPlaceType
        self.categoryKeys = categoryKeys
        self.tags = tags
        self.isFavorite = isFavorite
        self.weatherCondition = weatherCondition
        self.weatherTemperature = weatherTemperature
        self.weatherIcon = weatherIcon
        self.visibility = visibility
    }
}
