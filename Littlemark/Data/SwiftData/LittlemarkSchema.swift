import Foundation
import SwiftData

/// Store schema shipped in 1.0.
///
/// Before changing any `@Model` after release: freeze copies of the current models
/// inside this enum, add `LittlemarkSchemaV2` with the new models, and add a
/// `MigrationStage` from V1 to V2 in `LittlemarkMigrationPlan`.
nonisolated enum LittlemarkSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [SDMoment.self, SDMediaItem.self, SDUser.self]
    }
}

nonisolated enum LittlemarkMigrationPlan: SchemaMigrationPlan {
    static var currentSchema: any VersionedSchema.Type { LittlemarkSchemaV1.self }

    static var schemas: [any VersionedSchema.Type] {
        [LittlemarkSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
