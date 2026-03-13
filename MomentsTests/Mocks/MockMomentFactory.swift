import Foundation
@testable import Moments

enum MockMomentFactory {
    static let defaultUserId = User.default.id
    static let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    static func makeMoment(
        id: UUID = UUID(),
        userId: UUID? = nil,
        createdAt: Date? = nil,
        title: String? = "Test Moment",
        text: String? = "A test moment description",
        mediaItems: [MediaItem] = [],
        voiceNote: VoiceNote? = nil,
        location: Location? = nil,
        categories: [MomentCategory] = [],
        tags: [String] = [],
        isFavorite: Bool = false,
        weather: Weather? = nil,
        visibility: MomentVisibility = .private
    ) -> Moment {
        Moment(
            id: id,
            userId: userId ?? defaultUserId,
            createdAt: createdAt ?? fixedDate,
            updatedAt: createdAt ?? fixedDate,
            title: title,
            text: text,
            mediaItems: mediaItems,
            voiceNote: voiceNote,
            location: location,
            categories: categories,
            tags: tags,
            isFavorite: isFavorite,
            weather: weather,
            visibility: visibility
        )
    }

    static func makePhotoMoment(id: UUID = UUID()) -> Moment {
        let mediaItem = makePhotoMediaItem(momentId: id)
        return makeMoment(
            id: id,
            title: "Photo Moment",
            mediaItems: [mediaItem]
        )
    }

    static func makeVideoMoment(id: UUID = UUID()) -> Moment {
        let mediaItem = makeVideoMediaItem(momentId: id)
        return makeMoment(
            id: id,
            title: "Video Moment",
            mediaItems: [mediaItem]
        )
    }

    static func makeVoiceOnlyMoment(id: UUID = UUID()) -> Moment {
        makeMoment(
            id: id,
            title: "Voice Moment",
            voiceNote: makeVoiceNote()
        )
    }

    static func makeFullMoment(id: UUID = UUID()) -> Moment {
        let photoItem = makePhotoMediaItem(momentId: id, sortOrder: 0)
        let videoItem = makeVideoMediaItem(momentId: id, sortOrder: 1)
        return makeMoment(
            id: id,
            title: "Full Moment",
            text: "A moment with everything",
            mediaItems: [photoItem, videoItem],
            voiceNote: makeVoiceNote(),
            location: makeLocation(),
            categories: [MomentCategory.predefined[0], MomentCategory.predefined[4]],
            tags: ["test", "full"],
            isFavorite: true,
            weather: makeWeather()
        )
    }

    static func makePhotoMediaItem(
        id: UUID = UUID(),
        momentId: UUID = UUID(),
        sortOrder: Int = 0
    ) -> MediaItem {
        MediaItem(
            id: id,
            momentId: momentId,
            type: .photo,
            filePath: "Media/photo_\(id.uuidString).jpg",
            width: 1920,
            height: 1080,
            sortOrder: sortOrder
        )
    }

    static func makeVideoMediaItem(
        id: UUID = UUID(),
        momentId: UUID = UUID(),
        sortOrder: Int = 0
    ) -> MediaItem {
        MediaItem(
            id: id,
            momentId: momentId,
            type: .video,
            filePath: "Media/video_\(id.uuidString).mp4",
            thumbnailPath: "Thumbnails/thumb_\(id.uuidString).jpg",
            duration: 15.0,
            width: 1920,
            height: 1080,
            sortOrder: sortOrder
        )
    }

    static func makeVoiceNote() -> VoiceNote {
        VoiceNote(
            filePath: "Voice/note.m4a",
            duration: 10.0,
            transcript: "This is a test transcript"
        )
    }

    static func makeLocation() -> Location {
        Location(
            latitude: 10.762622,
            longitude: 106.660172,
            name: "Ho Chi Minh City",
            address: "123 Nguyen Hue, District 1",
            placeType: "city"
        )
    }

    static func makeWeather() -> Weather {
        Weather(
            condition: "Sunny",
            temperature: 32.0,
            icon: "sun.max"
        )
    }
}
