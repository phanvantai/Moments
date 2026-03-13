import Testing
import Foundation
@testable import Moments

struct CreateMomentUseCaseTests {
    let mockRepo = MockMomentRepository()

    var sut: CreateMomentUseCase {
        CreateMomentUseCase(momentRepository: mockRepo)
    }

    @Test func test_execute_withMedia_createsMoment() async throws {
        let moment = MockMomentFactory.makePhotoMoment()

        try await sut.execute(moment)

        #expect(mockRepo.createCallCount == 1)
        #expect(mockRepo.lastCreatedMoment == moment)
    }

    @Test func test_execute_withVoiceOnly_createsMoment() async throws {
        let moment = MockMomentFactory.makeVoiceOnlyMoment()

        try await sut.execute(moment)

        #expect(mockRepo.createCallCount == 1)
    }

    @Test func test_execute_withNoMedia_throwsNoMediaError() async {
        let moment = MockMomentFactory.makeMoment() // no media, no voice

        await #expect(throws: CreateMomentError.noMedia) {
            try await sut.execute(moment)
        }
        #expect(mockRepo.createCallCount == 0)
    }

    @Test func test_execute_repoThrows_propagatesError() async {
        let moment = MockMomentFactory.makePhotoMoment()
        mockRepo.errorToThrow = TestError.generic

        await #expect(throws: TestError.self) {
            try await sut.execute(moment)
        }
    }
}

private enum TestError: Error {
    case generic
}
