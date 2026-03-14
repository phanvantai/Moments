import Foundation
import SwiftUI

@Observable
@MainActor
final class TimelineViewModel {
    private(set) var moments: [Moment] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var viewMode: ViewMode {
        didSet {
            UserDefaults.standard.set(viewMode.rawValue, forKey: Self.viewModeKey)
        }
    }

    static let viewModeKey = "moments_view_mode"

    private let fetchMomentsUseCase: FetchMomentsUseCaseProtocol
    private let deleteMomentUseCase: DeleteMomentUseCaseProtocol

    init(
        fetchMomentsUseCase: FetchMomentsUseCaseProtocol,
        deleteMomentUseCase: DeleteMomentUseCaseProtocol
    ) {
        self.fetchMomentsUseCase = fetchMomentsUseCase
        self.deleteMomentUseCase = deleteMomentUseCase
        let stored = UserDefaults.standard.string(forKey: Self.viewModeKey)
        self.viewMode = ViewMode(rawValue: stored ?? "") ?? .timeline
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

    func toggleViewMode() {
        viewMode = viewMode == .timeline ? .grid : .timeline
    }
}
