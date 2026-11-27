import Foundation
@testable import Littlemark

final class MockCreateMomentUseCase: CreateMomentUseCaseProtocol, @unchecked Sendable {
    var executeCallCount = 0
    var lastExecutedMoment: Moment?
    var errorToThrow: Error?

    func execute(_ moment: Moment) async throws {
        executeCallCount += 1
        lastExecutedMoment = moment
        if let error = errorToThrow { throw error }
    }
}
