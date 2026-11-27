import Testing
import Foundation
import SwiftUI
@testable import Littlemark

// MARK: - Edge Case Tests

@MainActor
struct EdgeCaseTests {

    // MARK: - Moment with 10+ media items

    @Test func test_moment_tenPlusMedia_handlesCorrectly() {
        var mediaItems: [MediaItem] = []
        let momentId = UUID()
        for i in 0..<15 {
            mediaItems.append(MediaItem(
                momentId: momentId,
                type: i % 2 == 0 ? .photo : .video,
                filePath: "Media/item_\(i).jpg",
                width: 1920,
                height: 1080,
                sortOrder: i
            ))
        }

        let moment = Moment(
            userId: User.default.id,
            mediaItems: mediaItems
        )

        #expect(moment.mediaItems.count == 15)
        #expect(moment.hasMedia == true)
    }

    // MARK: - Text 1000+ chars does not break

    @Test func test_moment_longText_doesNotBreak() {
        let longText = String(repeating: "A very long text content. ", count: 100)
        #expect(longText.count > 1000)

        let moment = Moment(
            userId: User.default.id,
            text: longText,
            mediaItems: [MockMomentFactory.makePhotoMediaItem()]
        )

        #expect(moment.text == longText)
        #expect(moment.text?.count ?? 0 > 1000)
    }

    @Test func test_displayTitle_longText_returnsFullText_viewTruncates() {
        let longText = String(repeating: "X", count: 2000)
        let moment = MockMomentFactory.makeMoment(
            title: nil,
            text: longText
        )

        let title = MomentDisplayHelper.displayTitle(for: moment)

        // GridCardView / TimelineNodeView use lineLimit(2), which adds the ellipsis
        #expect(title == longText)
    }

    // MARK: - Voice duration = 0

    @Test func test_voiceNote_zeroDuration_graceful() {
        let voiceNote = VoiceNote(
            filePath: "Voice/zero.m4a",
            duration: 0,
            transcript: nil
        )

        #expect(voiceNote.duration == 0)
        #expect(voiceNote.filePath == "Voice/zero.m4a")
    }

    @Test func test_durationFormatter_zeroDuration() {
        let formatted = DurationFormatter.shortFormat(0)
        #expect(!formatted.isEmpty)
    }

    @Test func test_durationFormatter_paddedFormat_zeroDuration() {
        let formatted = DurationFormatter.paddedFormat(0)
        #expect(!formatted.isEmpty)
    }

    // MARK: - Location (0, 0)

    @Test func test_location_zeroCoordinates_doesNotCrash() {
        let location = Location(
            latitude: 0,
            longitude: 0,
            name: nil,
            address: nil,
            placeType: nil
        )

        #expect(location.latitude == 0)
        #expect(location.longitude == 0)
    }

    @Test func test_location_zeroCoordinates_distanceCalculation() {
        let origin = Location(latitude: 0, longitude: 0)
        let other = Location(latitude: 1, longitude: 1)

        let distance = origin.distance(to: other)

        #expect(distance > 0)
    }

    @Test func test_location_sameLocation_zeroDistance() {
        let loc = Location(latitude: 10.762622, longitude: 106.660172)

        let distance = loc.distance(to: loc)

        #expect(distance == 0)
    }

    // MARK: - Category key does not exist

    @Test func test_categoryFind_nonExistentKey_returnsNil() {
        let category = MomentCategory.find(byKey: "nonexistent-key")

        #expect(category == nil)
    }

    @Test func test_categoryFind_emptyKey_returnsNil() {
        let category = MomentCategory.find(byKey: "")

        #expect(category == nil)
    }

    @Test func test_displayHelper_unknownCategoryKey_returnsDefaultColor() {
        let color = MomentDisplayHelper.color(forCategoryKey: "unknown-key")

        // Should return brand blue (default)
        #expect(color == BrandColors.categoryBlue)
    }

    // MARK: - Negative temperature

    @Test func test_weather_negativeTemperature_displaysCorrectly() {
        let weather = Weather(
            condition: "Snowy",
            temperature: -15.5,
            icon: "snowflake"
        )

        #expect(weather.temperature == -15.5)
        #expect(Int(weather.temperature) == -15)
    }

    @Test func test_weather_extremeNegativeTemperature() {
        let weather = Weather(
            condition: "Extreme Cold",
            temperature: -40.0,
            icon: "thermometer.snowflake"
        )

        #expect(weather.temperature == -40.0)
        #expect(weather.condition == "Extreme Cold")
    }

    @Test func test_weather_zeroTemperature() {
        let weather = Weather(
            condition: "Freezing",
            temperature: 0.0,
            icon: "snowflake"
        )

        #expect(Int(weather.temperature) == 0)
    }

    // MARK: - Delete moment when file already missing

    @Test func test_deleteMoment_mediaDeleteFails_momentStillDeleted() async throws {
        let mockMomentRepo = MockMomentRepository()
        let mockMediaRepo = MockMediaRepository()
        let moment = MockMomentFactory.makePhotoMoment()
        mockMomentRepo.momentToReturn = moment
        // Simulate file already missing
        mockMediaRepo.errorToThrow = NSError(domain: "file", code: 404, userInfo: nil)

        let sut = DeleteMomentUseCase(
            momentRepository: mockMomentRepo,
            mediaRepository: mockMediaRepo
        )

        // Should NOT throw even though media deletion fails
        try await sut.execute(momentId: moment.id)

        #expect(mockMomentRepo.deleteCallCount == 1)
    }

    // MARK: - Moment with all nil optional fields

    @Test func test_moment_allNilOptionals_handlesGracefully() {
        let moment = Moment(userId: User.default.id)

        #expect(moment.title == nil)
        #expect(moment.text == nil)
        #expect(moment.voiceNote == nil)
        #expect(moment.location == nil)
        #expect(moment.weather == nil)
        #expect(moment.mediaItems.isEmpty)
        #expect(moment.categories.isEmpty)
        #expect(moment.tags.isEmpty)
        #expect(moment.hasMedia == false)
    }

    @Test func test_displayHelper_momentWithNoContent_returnsDefault() {
        let moment = Moment(userId: User.default.id)

        let title = MomentDisplayHelper.displayTitle(for: moment)

        #expect(title == "Moment")
    }

    // MARK: - Concurrent-safe model operations

    @Test func test_moment_hashable_worksInSet() {
        let m1 = MockMomentFactory.makePhotoMoment()
        let m2 = MockMomentFactory.makeVideoMoment()
        let m3 = m1

        var set = Set<Moment>()
        set.insert(m1)
        set.insert(m2)
        set.insert(m3)

        #expect(set.count == 2)
    }

    // MARK: - MediaItem edge cases

    @Test func test_mediaItem_zeroWidthHeight() {
        let item = MediaItem(
            momentId: UUID(),
            type: .photo,
            filePath: "test.jpg",
            width: 0,
            height: 0
        )

        #expect(item.width == 0)
        #expect(item.height == 0)
    }

    @Test func test_mediaItem_nilOptionals() {
        let item = MediaItem(
            momentId: UUID(),
            type: .photo,
            filePath: "test.jpg",
            width: 100,
            height: 100
        )

        #expect(item.thumbnailPath == nil)
        #expect(item.duration == nil)
    }

    // MARK: - User default

    @Test func test_userDefault_hasStableId() {
        let user1 = User.default
        let user2 = User.default

        #expect(user1.id == user2.id)
    }

    @Test func test_userDefault_hasExpectedName() {
        #expect(User.default.displayName == "Me")
    }
}
