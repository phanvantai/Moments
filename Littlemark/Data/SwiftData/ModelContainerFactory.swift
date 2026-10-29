import Foundation
import SwiftData

/// Builds the app's `ModelContainer`: on-device only (no CloudKit) and versioned
/// through `LittlemarkMigrationPlan`.
nonisolated enum ModelContainerFactory {
    enum Storage {
        /// SwiftData's default store in Application Support.
        case `default`
        case file(URL)
        case inMemory
    }

    static func makeConfiguration(storage: Storage = .default) -> ModelConfiguration {
        let schema = Schema(versionedSchema: LittlemarkMigrationPlan.currentSchema)
        switch storage {
        case .default:
            return ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        case .file(let url):
            return ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        case .inMemory:
            return ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        }
    }

    static func make(storage: Storage = .default) throws -> ModelContainer {
        let configuration = makeConfiguration(storage: storage)
        if !configuration.isStoredInMemoryOnly {
            try FileManager.default.createDirectory(
                at: configuration.url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
        }
        return try ModelContainer(
            for: Schema(versionedSchema: LittlemarkMigrationPlan.currentSchema),
            migrationPlan: LittlemarkMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
