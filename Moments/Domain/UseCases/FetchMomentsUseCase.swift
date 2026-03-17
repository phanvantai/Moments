import Foundation

protocol FetchMomentsUseCaseProtocol: Sendable {
    func execute() async throws -> [Moment]
    func execute(byId id: UUID) async throws -> Moment?
}

struct FetchMomentsUseCase: FetchMomentsUseCaseProtocol {
    private let momentRepository: MomentRepositoryProtocol

    init(momentRepository: MomentRepositoryProtocol) {
        self.momentRepository = momentRepository
    }

    func execute() async throws -> [Moment] {
        let moments = try await momentRepository.fetchAll()
        return moments.sorted { $0.createdAt < $1.createdAt }
    }

    func execute(byId id: UUID) async throws -> Moment? {
        try await momentRepository.fetch(byId: id)
    }
}
