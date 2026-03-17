import Testing
import Foundation
@testable import Moments

struct FetchMomentsUseCaseTests {
    let mockRepo = MockMomentRepository()

    var sut: FetchMomentsUseCase {
        FetchMomentsUseCase(momentRepository: mockRepo)
    }

    @Test func test_execute_returnsMomentsSortedByCreatedAtAscending() async throws {
        let older = MockMomentFactory.makeMoment(
            createdAt: Date(timeIntervalSince1970: 1_000_000)
        )
        let newer = MockMomentFactory.makeMoment(
            createdAt: Date(timeIntervalSince1970: 2_000_000)
        )
        mockRepo.momentsToReturn = [newer, older]

        let result = try await sut.execute()

        #expect(result.count == 2)
        #expect(result[0].createdAt < result[1].createdAt)
        #expect(mockRepo.fetchAllCallCount == 1)
    }

    @Test func test_execute_emptyRepo_returnsEmptyArray() async throws {
        mockRepo.momentsToReturn = []

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }

    @Test func test_executeById_existingMoment_returnsMoment() async throws {
        let moment = MockMomentFactory.makePhotoMoment()
        mockRepo.momentToReturn = moment

        let result = try await sut.execute(byId: moment.id)

        #expect(result == moment)
        #expect(mockRepo.fetchByIdCallCount == 1)
    }

    @Test func test_executeById_nonExistingMoment_returnsNil() async throws {
        mockRepo.momentToReturn = nil

        let result = try await sut.execute(byId: UUID())

        #expect(result == nil)
    }

    @Test func test_execute_repoThrows_propagatesError() async {
        mockRepo.errorToThrow = TestError.generic

        await #expect(throws: TestError.self) {
            try await sut.execute()
        }
    }
}

private enum TestError: Error {
    case generic
}
