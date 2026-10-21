import Foundation

protocol CreateMomentUseCaseProtocol: Sendable {
    func execute(_ moment: Moment) async throws
}

struct CreateMomentUseCase: CreateMomentUseCaseProtocol {
    private let momentRepository: MomentRepositoryProtocol

    init(momentRepository: MomentRepositoryProtocol) {
        self.momentRepository = momentRepository
    }

    func execute(_ moment: Moment) async throws {
        guard moment.hasMedia else {
            throw CreateMomentError.noMedia
        }
        try await momentRepository.create(moment)
    }
}

enum CreateMomentError: Error, Equatable {
    case noMedia
}
