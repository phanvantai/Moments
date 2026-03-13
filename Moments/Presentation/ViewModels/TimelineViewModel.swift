import Foundation

@Observable
@MainActor
final class TimelineViewModel {
    private(set) var moments: [Moment] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let fetchMomentsUseCase: FetchMomentsUseCaseProtocol
    private let deleteMomentUseCase: DeleteMomentUseCaseProtocol

    init(
        fetchMomentsUseCase: FetchMomentsUseCaseProtocol,
        deleteMomentUseCase: DeleteMomentUseCaseProtocol
    ) {
        self.fetchMomentsUseCase = fetchMomentsUseCase
        self.deleteMomentUseCase = deleteMomentUseCase
    }

    func loadMoments() async {
        isLoading = true
        errorMessage = nil
        do {
            moments = try await fetchMomentsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteMoment(id: UUID) async {
        do {
            try await deleteMomentUseCase.execute(momentId: id)
            moments.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
