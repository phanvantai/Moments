import Testing
import Foundation
import SwiftData
@testable import Littlemark

struct MomentRepositoryTests {

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([SDMoment.self, SDMediaItem.self, SDUser.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    // MARK: - Create

    @Test func test_create_insertsMoment() async throws {
        let container = try makeContainer()
        let sut = MomentRepository(modelContainer: container)
        let moment = MockMomentFactory.makePhotoMoment()

        try await sut.create(moment)

        let fetched = try await sut.fetchAll()
        #expect(fetched.count == 1)
        #expect(fetched.first?.id == moment.id)
    }

    // MARK: - Fetch All

    @Test func test_fetchAll_emptyStore_returnsEmpty() async throws {
        let container = try makeContainer()
        let sut = MomentRepository(modelContainer: container)

        let result = try await sut.fetchAll()

        #expect(result.isEmpty)
    }

    @Test func test_fetchAll_multipleMoments_returnsAll() async throws {
        let container = try makeContainer()
        let sut = MomentRepository(modelContainer: container)

        try await sut.create(MockMomentFactory.makePhotoMoment())
        try await sut.create(MockMomentFactory.makeVoiceOnlyMoment())

        let result = try await sut.fetchAll()
        #expect(result.count == 2)
    }

    // MARK: - Fetch By ID

    @Test func test_fetchById_existingMoment_returnsMoment() async throws {
        let container = try makeContainer()
        let sut = MomentRepository(modelContainer: container)
        let moment = MockMomentFactory.makePhotoMoment()

        try await sut.create(moment)

        let fetched = try await sut.fetch(byId: moment.id)
        #expect(fetched?.id == moment.id)
        #expect(fetched?.title == moment.title)
    }

    @Test func test_fetchById_nonExistingMoment_returnsNil() async throws {
        let container = try makeContainer()
        let sut = MomentRepository(modelContainer: container)

        let fetched = try await sut.fetch(byId: UUID())
        #expect(fetched == nil)
    }

    // MARK: - Update

    @Test func test_update_existingMoment_updatesFields() async throws {
        let container = try makeContainer()
        let sut = MomentRepository(modelContainer: container)
        var moment = MockMomentFactory.makePhotoMoment()

        try await sut.create(moment)

        moment.title = "Updated Title"
        moment.text = "Updated Text"
        moment.isFavorite = true
        try await sut.update(moment)

        let fetched = try await sut.fetch(byId: moment.id)
        #expect(fetched?.title == "Updated Title")
        #expect(fetched?.text == "Updated Text")
        #expect(fetched?.isFavorite == true)
    }

    @Test func test_update_nonExistingMoment_throwsError() async throws {
        let container = try makeContainer()
        let sut = MomentRepository(modelContainer: container)
        let moment = MockMomentFactory.makePhotoMoment()

        await #expect(throws: MomentRepositoryError.self) {
            try await sut.update(moment)
        }
    }

    // MARK: - Delete

    @Test func test_delete_existingMoment_removesMoment() async throws {
        let container = try makeContainer()
        let sut = MomentRepository(modelContainer: container)
        let moment = MockMomentFactory.makePhotoMoment()

        try await sut.create(moment)
        try await sut.delete(byId: moment.id)

        let fetched = try await sut.fetchAll()
        #expect(fetched.isEmpty)
    }

    @Test func test_delete_nonExistingMoment_throwsError() async throws {
        let container = try makeContainer()
        let sut = MomentRepository(modelContainer: container)

        await #expect(throws: MomentRepositoryError.self) {
            try await sut.delete(byId: UUID())
        }
    }

    // MARK: - Roundtrip (Domain → SwiftData → Domain)

    @Test func test_roundtrip_fullMoment_preservesAllFields() async throws {
        let container = try makeContainer()
        let sut = MomentRepository(modelContainer: container)
        let original = MockMomentFactory.makeFullMoment()

        try await sut.create(original)
        let fetched = try await sut.fetch(byId: original.id)

        #expect(fetched != nil)
        #expect(fetched?.id == original.id)
        #expect(fetched?.userId == original.userId)
        #expect(fetched?.title == original.title)
        #expect(fetched?.text == original.text)
        #expect(fetched?.isFavorite == original.isFavorite)
        #expect(fetched?.tags == original.tags)
        #expect(fetched?.visibility == original.visibility)
        #expect(fetched?.voiceNote?.filePath == original.voiceNote?.filePath)
        #expect(fetched?.voiceNote?.duration == original.voiceNote?.duration)
        #expect(fetched?.location?.latitude == original.location?.latitude)
        #expect(fetched?.location?.longitude == original.location?.longitude)
        #expect(fetched?.weather?.condition == original.weather?.condition)
        #expect(fetched?.weather?.temperature == original.weather?.temperature)
        #expect(fetched?.categories.count == original.categories.count)
        #expect(fetched?.mediaItems.count == original.mediaItems.count)
    }
}
