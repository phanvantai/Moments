import Testing
import Foundation
import SwiftData
@testable import Littlemark

struct ModelContainerFactoryTests {

    private func makeTemporaryStoreURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("Littlemark.store")
    }

    // MARK: - Configuration

    @Test func test_makeConfiguration_default_disablesCloudKit() {
        let config = ModelContainerFactory.makeConfiguration()

        #expect(config.cloudKitContainerIdentifier == nil)
    }

    @Test func test_makeConfiguration_inMemory_isStoredInMemoryOnly() {
        let config = ModelContainerFactory.makeConfiguration(storage: .inMemory)

        #expect(config.isStoredInMemoryOnly)
    }

    @Test func test_makeConfiguration_fileStorage_usesGivenURL() {
        let url = makeTemporaryStoreURL()

        let config = ModelContainerFactory.makeConfiguration(storage: .file(url))

        #expect(config.url == url)
        #expect(!config.isStoredInMemoryOnly)
    }

    // MARK: - Schema

    @Test func test_currentSchema_containsAllModels() {
        let schema = Schema(versionedSchema: LittlemarkMigrationPlan.currentSchema)
        let names = Set(schema.entities.map(\.name))

        #expect(names == ["SDMoment", "SDMediaItem", "SDUser"])
    }

    @Test func test_migrationPlan_latestSchemaIsCurrent() {
        let latest = LittlemarkMigrationPlan.schemas.last

        #expect(latest == LittlemarkMigrationPlan.currentSchema)
    }

    // MARK: - Make

    @Test func test_make_inMemory_persistsMoments() async throws {
        let container = try ModelContainerFactory.make(storage: .inMemory)
        let repository = MomentRepository(modelContainer: container)
        let moment = MockMomentFactory.makePhotoMoment()

        try await repository.create(moment)

        let fetched = try await repository.fetchAll()
        #expect(fetched.map(\.id) == [moment.id])
    }

    @Test func test_make_reopenExistingStore_keepsMoments() async throws {
        let url = makeTemporaryStoreURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let moment = MockMomentFactory.makePhotoMoment()

        do {
            let container = try ModelContainerFactory.make(storage: .file(url))
            try await MomentRepository(modelContainer: container).create(moment)
        }

        let reopened = try ModelContainerFactory.make(storage: .file(url))
        let fetched = try await MomentRepository(modelContainer: reopened).fetchAll()
        #expect(fetched.map(\.id) == [moment.id])
    }

    @Test func test_make_fileStorage_createsMissingParentDirectory() throws {
        let url = makeTemporaryStoreURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        _ = try ModelContainerFactory.make(storage: .file(url))

        #expect(FileManager.default.fileExists(atPath: url.deletingLastPathComponent().path))
    }
}
