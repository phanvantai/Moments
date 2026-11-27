import Testing
import Foundation
@testable import Littlemark

struct DeleteMomentUseCaseTests {
    let mockMomentRepo = MockMomentRepository()
    let mockMediaRepo = MockMediaRepository()

    var sut: DeleteMomentUseCase {
        DeleteMomentUseCase(
            momentRepository: mockMomentRepo,
            mediaRepository: mockMediaRepo
        )
    }

    @Test func test_execute_existingMomentWithMedia_deletesFilesAndMoment() async throws {
        let moment = MockMomentFactory.makeFullMoment()
        mockMomentRepo.momentToReturn = moment

        try await sut.execute(momentId: moment.id)

        #expect(mockMomentRepo.fetchByIdCallCount == 1)
        #expect(mockMomentRepo.deleteCallCount == 1)
        #expect(mockMomentRepo.lastDeletedId == moment.id)
        // 2 media items deleted + 1 thumbnail for video
        #expect(mockMediaRepo.deleteMediaCallCount == 3)
        // 1 voice note deleted
        #expect(mockMediaRepo.deleteVoiceNoteCallCount == 1)
    }

    @Test func test_execute_momentNotFound_throwsError() async {
        mockMomentRepo.momentToReturn = nil

        await #expect(throws: DeleteMomentError.momentNotFound) {
            try await sut.execute(momentId: UUID())
        }
        #expect(mockMomentRepo.deleteCallCount == 0)
    }

    @Test func test_execute_momentWithNoFiles_onlyDeletesMoment() async throws {
        let moment = MockMomentFactory.makePhotoMoment()
        mockMomentRepo.momentToReturn = moment

        try await sut.execute(momentId: moment.id)

        #expect(mockMomentRepo.deleteCallCount == 1)
        #expect(mockMediaRepo.deleteMediaCallCount == 1) // 1 photo file
        #expect(mockMediaRepo.deleteVoiceNoteCallCount == 0)
    }

    @Test func test_execute_mediaDeleteFails_stillDeletesMoment() async throws {
        let moment = MockMomentFactory.makePhotoMoment()
        mockMomentRepo.momentToReturn = moment
        mockMediaRepo.errorToThrow = TestError.generic

        // Should not throw even though media delete fails
        try await sut.execute(momentId: moment.id)

        #expect(mockMomentRepo.deleteCallCount == 1)
    }
}

private enum TestError: Error {
    case generic
}
