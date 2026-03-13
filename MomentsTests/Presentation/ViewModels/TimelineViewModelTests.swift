import Testing
import Foundation
@testable import Moments

@MainActor
struct TimelineViewModelTests {
    let mockFetchUseCase = MockFetchMomentsUseCase()
    let mockDeleteUseCase = MockDeleteMomentUseCase()

    var sut: TimelineViewModel {
        TimelineViewModel(
            fetchMomentsUseCase: mockFetchUseCase,
            deleteMomentUseCase: mockDeleteUseCase
        )
    }

    // MARK: - Load Moments

    @Test func test_loadMoments_success_setsMoments() async {
        let moments = [
            MockMomentFactory.makePhotoMoment(),
            MockMomentFactory.makeVoiceOnlyMoment()
        ]
        mockFetchUseCase.momentsToReturn = moments
        let vm = sut

        await vm.loadMoments()

        #expect(vm.moments.count == 2)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test func test_loadMoments_emptyResult_setsEmptyArray() async {
        mockFetchUseCase.momentsToReturn = []
        let vm = sut

        await vm.loadMoments()

        #expect(vm.moments.isEmpty)
        #expect(vm.isLoading == false)
    }

    @Test func test_loadMoments_failure_setsErrorMessage() async {
        mockFetchUseCase.errorToThrow = TestError.loadFailed
        let vm = sut

        await vm.loadMoments()

        #expect(vm.moments.isEmpty)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
    }

    // MARK: - Delete Moment

    @Test func test_deleteMoment_success_removesFromList() async {
        let moment = MockMomentFactory.makePhotoMoment()
        mockFetchUseCase.momentsToReturn = [moment]
        let vm = sut
        await vm.loadMoments()

        await vm.deleteMoment(id: moment.id)

        #expect(vm.moments.isEmpty)
        #expect(mockDeleteUseCase.executeCallCount == 1)
    }

    @Test func test_deleteMoment_failure_setsErrorMessage() async {
        let moment = MockMomentFactory.makePhotoMoment()
        mockFetchUseCase.momentsToReturn = [moment]
        let vm = sut
        await vm.loadMoments()
        mockDeleteUseCase.errorToThrow = TestError.deleteFailed

        await vm.deleteMoment(id: moment.id)

        #expect(vm.errorMessage != nil)
        // Moment should still be in list since delete failed
        #expect(vm.moments.count == 1)
    }
}

// MARK: - Mock Use Cases for ViewModel tests

final class MockFetchMomentsUseCase: FetchMomentsUseCaseProtocol, @unchecked Sendable {
    var executeCallCount = 0
    var executeByIdCallCount = 0
    var momentsToReturn: [Moment] = []
    var momentToReturn: Moment?
    var errorToThrow: Error?

    func execute() async throws -> [Moment] {
        executeCallCount += 1
        if let error = errorToThrow { throw error }
        return momentsToReturn
    }

    func execute(byId id: UUID) async throws -> Moment? {
        executeByIdCallCount += 1
        if let error = errorToThrow { throw error }
        return momentToReturn
    }
}

final class MockDeleteMomentUseCase: DeleteMomentUseCaseProtocol, @unchecked Sendable {
    var executeCallCount = 0
    var lastDeletedMomentId: UUID?
    var errorToThrow: Error?

    func execute(momentId: UUID) async throws {
        executeCallCount += 1
        lastDeletedMomentId = momentId
        if let error = errorToThrow { throw error }
    }
}

private enum TestError: Error {
    case loadFailed
    case deleteFailed
}
