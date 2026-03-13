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
