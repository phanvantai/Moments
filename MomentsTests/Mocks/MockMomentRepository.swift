import Foundation
@testable import Moments

final class MockMomentRepository: MomentRepositoryProtocol, @unchecked Sendable {
    // Call tracking
    var createCallCount = 0
    var fetchAllCallCount = 0
    var fetchByIdCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0

    // Captured arguments
    var lastCreatedMoment: Moment?
    var lastFetchedId: UUID?
    var lastUpdatedMoment: Moment?
    var lastDeletedId: UUID?

    // Configurable return values
    var momentsToReturn: [Moment] = []
    var momentToReturn: Moment?
    var errorToThrow: Error?

    func create(_ moment: Moment) async throws {
        createCallCount += 1
        lastCreatedMoment = moment
        if let error = errorToThrow { throw error }
    }

    func fetchAll() async throws -> [Moment] {
        fetchAllCallCount += 1
        if let error = errorToThrow { throw error }
        return momentsToReturn
    }

    var fetchRecentCallCount = 0
    var lastFetchLimit: Int?
    var lastFetchOffset: Int?

    func fetchRecent(limit: Int, offset: Int) async throws -> [Moment] {
        fetchRecentCallCount += 1
        lastFetchLimit = limit
        lastFetchOffset = offset
        if let error = errorToThrow { throw error }
        let sorted = momentsToReturn.sorted { $0.createdAt > $1.createdAt }
        let start = min(offset, sorted.count)
        let end = min(offset + limit, sorted.count)
        return Array(sorted[start..<end])
    }

    func fetch(byId id: UUID) async throws -> Moment? {
        fetchByIdCallCount += 1
        lastFetchedId = id
        if let error = errorToThrow { throw error }
        return momentToReturn
    }

    func update(_ moment: Moment) async throws {
        updateCallCount += 1
        lastUpdatedMoment = moment
        if let error = errorToThrow { throw error }
    }

    func delete(byId id: UUID) async throws {
        deleteCallCount += 1
        lastDeletedId = id
        if let error = errorToThrow { throw error }
    }
}
