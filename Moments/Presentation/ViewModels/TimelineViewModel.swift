import Foundation
import SwiftUI

@Observable
@MainActor
final class TimelineViewModel {
    private(set) var moments: [Moment] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasMoreOlderMoments = true
    private(set) var errorMessage: String?
    var viewMode: ViewMode {
        didSet {
            UserDefaults.standard.set(viewMode.rawValue, forKey: Self.viewModeKey)
        }
    }

    static let viewModeKey = "moments_view_mode"
    static let pageSize = 20

    private let fetchMomentsUseCase: FetchMomentsUseCaseProtocol
    private let deleteMomentUseCase: DeleteMomentUseCaseProtocol
    private var currentOffset = 0

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
        currentOffset = 0
        hasMoreOlderMoments = true
        do {
            let fetched = try await fetchMomentsUseCase.execute(limit: Self.pageSize, offset: 0)
            moments = fetched
            currentOffset = fetched.count
            if fetched.count < Self.pageSize {
                hasMoreOlderMoments = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadMoreMoments() async {
        guard !isLoadingMore, hasMoreOlderMoments else { return }
        isLoadingMore = true
        do {
            let older = try await fetchMomentsUseCase.execute(limit: Self.pageSize, offset: currentOffset)
            if older.isEmpty {
                hasMoreOlderMoments = false
            } else {
                // Older moments go to the front (left side of timeline)
                moments.insert(contentsOf: older, at: 0)
                currentOffset += older.count
                if older.count < Self.pageSize {
                    hasMoreOlderMoments = false
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingMore = false
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
