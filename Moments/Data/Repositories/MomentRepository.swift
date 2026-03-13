import Foundation
import SwiftData

actor MomentRepository: MomentRepositoryProtocol {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func create(_ moment: Moment) async throws {
        let context = ModelContext(modelContainer)
        let sdMoment = MomentMapper.toSDModel(moment)
        context.insert(sdMoment)
        try context.save()
    }

    func fetchAll() async throws -> [Moment] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<SDMoment>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let sdMoments = try context.fetch(descriptor)
        return sdMoments.map { MomentMapper.toDomain($0) }
    }

    func fetch(byId id: UUID) async throws -> Moment? {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<SDMoment>(
            predicate: #Predicate { $0.id == id }
        )
        let sdMoments = try context.fetch(descriptor)
        return sdMoments.first.map { MomentMapper.toDomain($0) }
    }

    func update(_ moment: Moment) async throws {
        let context = ModelContext(modelContainer)
        let id = moment.id
        let descriptor = FetchDescriptor<SDMoment>(
            predicate: #Predicate { $0.id == id }
        )
        guard let sdMoment = try context.fetch(descriptor).first else {
            throw MomentRepositoryError.momentNotFound
        }

        // Remove old media items
        for mediaItem in sdMoment.mediaItems {
            context.delete(mediaItem)
        }

        MomentMapper.update(sdMoment, from: moment)
        sdMoment.mediaItems = moment.mediaItems.map { MomentMapper.toSDModel($0) }

        try context.save()
    }

    func delete(byId id: UUID) async throws {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<SDMoment>(
            predicate: #Predicate { $0.id == id }
        )
        guard let sdMoment = try context.fetch(descriptor).first else {
            throw MomentRepositoryError.momentNotFound
        }
        context.delete(sdMoment)
        try context.save()
    }
}

enum MomentRepositoryError: Error, Equatable {
    case momentNotFound
}
