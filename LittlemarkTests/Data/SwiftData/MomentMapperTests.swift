import Testing
import Foundation
@testable import Littlemark

struct MomentMapperTests {

    // MARK: - Domain → SwiftData

    @Test func test_toSDModel_moment_mapsAllFields() {
        let moment = MockMomentFactory.makeFullMoment()

        let sdMoment = MomentMapper.toSDModel(moment)

        #expect(sdMoment.id == moment.id)
        #expect(sdMoment.userId == moment.userId)
        #expect(sdMoment.title == moment.title)
        #expect(sdMoment.text == moment.text)
        #expect(sdMoment.isFavorite == moment.isFavorite)
        #expect(sdMoment.tags == moment.tags)
        #expect(sdMoment.visibility == moment.visibility.rawValue)
        #expect(sdMoment.mediaItems?.count == moment.mediaItems.count)
        #expect(sdMoment.categoryKeys.count == moment.categories.count)
    }

    @Test func test_toSDModel_moment_mapsLocation() {
        let moment = MockMomentFactory.makeFullMoment()

        let sdMoment = MomentMapper.toSDModel(moment)

        #expect(sdMoment.locationLatitude == moment.location?.latitude)
        #expect(sdMoment.locationLongitude == moment.location?.longitude)
        #expect(sdMoment.locationName == moment.location?.name)
        #expect(sdMoment.locationAddress == moment.location?.address)
    }

    @Test func test_toSDModel_moment_mapsVoiceNote() {
        let moment = MockMomentFactory.makeFullMoment()

        let sdMoment = MomentMapper.toSDModel(moment)

        #expect(sdMoment.voiceNoteFilePath == moment.voiceNote?.filePath)
        #expect(sdMoment.voiceNoteDuration == moment.voiceNote?.duration)
        #expect(sdMoment.voiceNoteTranscript == moment.voiceNote?.transcript)
    }

    @Test func test_toSDModel_moment_mapsWeather() {
        let moment = MockMomentFactory.makeFullMoment()

        let sdMoment = MomentMapper.toSDModel(moment)

        #expect(sdMoment.weatherCondition == moment.weather?.condition)
        #expect(sdMoment.weatherTemperature == moment.weather?.temperature)
        #expect(sdMoment.weatherIcon == moment.weather?.icon)
    }

    @Test func test_toSDModel_momentWithNilOptionals_mapsNils() {
        let moment = MockMomentFactory.makeMoment()

        let sdMoment = MomentMapper.toSDModel(moment)

        #expect(sdMoment.voiceNoteFilePath == nil)
        #expect(sdMoment.locationLatitude == nil)
        #expect(sdMoment.weatherCondition == nil)
    }

    @Test func test_toSDModel_mediaItem_mapsAllFields() {
        let mediaItem = MockMomentFactory.makeVideoMediaItem()

        let sdItem = MomentMapper.toSDModel(mediaItem)

        #expect(sdItem.id == mediaItem.id)
        #expect(sdItem.momentId == mediaItem.momentId)
        #expect(sdItem.type == mediaItem.type.rawValue)
        #expect(sdItem.filePath == mediaItem.filePath)
        #expect(sdItem.thumbnailPath == mediaItem.thumbnailPath)
        #expect(sdItem.duration == mediaItem.duration)
        #expect(sdItem.width == mediaItem.width)
        #expect(sdItem.height == mediaItem.height)
        #expect(sdItem.sortOrder == mediaItem.sortOrder)
    }

    // MARK: - SwiftData → Domain

    @Test func test_toDomain_sdMoment_mapsAllFields() {
        let sdMoment = SDMoment(
            id: UUID(),
            userId: UUID(),
            title: "Test",
            text: "Body",
            voiceNoteFilePath: "Voice/note.m4a",
            voiceNoteDuration: 10.0,
            voiceNoteTranscript: "transcript",
            locationLatitude: 10.0,
            locationLongitude: 106.0,
            locationName: "HCMC",
            categoryKeys: ["travel", "outdoor"],
            tags: ["tag1"],
            isFavorite: true,
            weatherCondition: "Sunny",
            weatherTemperature: 32.0,
            weatherIcon: "sun.max",
            visibility: "shared"
        )

        let moment = MomentMapper.toDomain(sdMoment)

        #expect(moment.id == sdMoment.id)
        #expect(moment.title == "Test")
        #expect(moment.voiceNote?.filePath == "Voice/note.m4a")
        #expect(moment.voiceNote?.duration == 10.0)
        #expect(moment.location?.latitude == 10.0)
        #expect(moment.location?.name == "HCMC")
        #expect(moment.weather?.condition == "Sunny")
        #expect(moment.categories.count == 2)
        #expect(moment.visibility == .shared)
        #expect(moment.isFavorite == true)
    }

    @Test func test_toDomain_sdMomentWithNils_handlesGracefully() {
        let sdMoment = SDMoment(
            userId: UUID(),
            visibility: "private"
        )

        let moment = MomentMapper.toDomain(sdMoment)

        #expect(moment.voiceNote == nil)
        #expect(moment.location == nil)
        #expect(moment.weather == nil)
        #expect(moment.categories.isEmpty)
    }

    @Test func test_toDomain_sdMomentWithInvalidVisibility_defaultsToPrivate() {
        let sdMoment = SDMoment(
            userId: UUID(),
            visibility: "invalid"
        )

        let moment = MomentMapper.toDomain(sdMoment)

        #expect(moment.visibility == .private)
    }

    @Test func test_toDomain_sdMediaItem_mapsAllFields() {
        let sdItem = SDMediaItem(
            momentId: UUID(),
            type: "video",
            filePath: "Media/vid.mp4",
            thumbnailPath: "Thumbnails/thumb.jpg",
            duration: 30.0,
            width: 1920,
            height: 1080,
            sortOrder: 2
        )

        let item = MomentMapper.toDomain(sdItem)

        #expect(item.type == .video)
        #expect(item.filePath == "Media/vid.mp4")
        #expect(item.thumbnailPath == "Thumbnails/thumb.jpg")
        #expect(item.duration == 30.0)
        #expect(item.sortOrder == 2)
    }

    @Test func test_toDomain_sdMediaItemWithInvalidType_defaultsToPhoto() {
        let sdItem = SDMediaItem(
            momentId: UUID(),
            type: "invalid",
            filePath: "file",
            width: 100,
            height: 100
        )

        let item = MomentMapper.toDomain(sdItem)

        #expect(item.type == .photo)
    }

    // MARK: - Update

    @Test func test_update_sdMoment_updatesAllFields() {
        let sdMoment = SDMoment(userId: UUID(), visibility: "private")
        var moment = MockMomentFactory.makeFullMoment()
        moment.title = "Updated"
        moment.isFavorite = true

        MomentMapper.update(sdMoment, from: moment)

        #expect(sdMoment.title == "Updated")
        #expect(sdMoment.isFavorite == true)
        #expect(sdMoment.voiceNoteFilePath == moment.voiceNote?.filePath)
        #expect(sdMoment.weatherCondition == moment.weather?.condition)
    }
}

// MARK: - UserMapper Tests

struct UserMapperTests {

    @Test func test_toSDModel_mapsAllFields() {
        let location = Location(latitude: 10.0, longitude: 106.0, name: "Home")
        let user = User(displayName: "Test", avatarPath: "avatar.jpg", homeLocation: location)

        let sdUser = UserMapper.toSDModel(user)

        #expect(sdUser.id == user.id)
        #expect(sdUser.displayName == "Test")
        #expect(sdUser.avatarPath == "avatar.jpg")
        #expect(sdUser.homeLocationLatitude == 10.0)
        #expect(sdUser.homeLocationLongitude == 106.0)
        #expect(sdUser.homeLocationName == "Home")
    }

    @Test func test_toDomain_mapsAllFields() {
        let sdUser = SDUser(
            displayName: "Test",
            avatarPath: "avatar.jpg",
            homeLocationLatitude: 10.0,
            homeLocationLongitude: 106.0,
            homeLocationName: "Home"
        )

        let user = UserMapper.toDomain(sdUser)

        #expect(user.displayName == "Test")
        #expect(user.avatarPath == "avatar.jpg")
        #expect(user.homeLocation?.latitude == 10.0)
        #expect(user.homeLocation?.name == "Home")
    }

    @Test func test_toDomain_noHomeLocation_returnsNil() {
        let sdUser = SDUser(displayName: "Test")

        let user = UserMapper.toDomain(sdUser)

        #expect(user.homeLocation == nil)
    }

    @Test func test_roundtrip_preservesAllFields() {
        let original = User(
            displayName: "Round Trip",
            avatarPath: "path.jpg",
            homeLocation: Location(latitude: 1.0, longitude: 2.0, name: "Place")
        )

        let sdUser = UserMapper.toSDModel(original)
        let result = UserMapper.toDomain(sdUser)

        #expect(result.id == original.id)
        #expect(result.displayName == original.displayName)
        #expect(result.avatarPath == original.avatarPath)
        #expect(result.homeLocation?.latitude == original.homeLocation?.latitude)
    }
}
