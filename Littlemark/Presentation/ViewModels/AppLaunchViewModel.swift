import Foundation
import Observation

/// Opens the store at launch. A failure shows `StoreErrorView` instead of crashing,
/// so the user's data is left untouched on disk.
@Observable
@MainActor
final class AppLaunchViewModel {
    private(set) var container: DependencyContainer?

    var didFailToLoadStore: Bool { container == nil }

    private let makeContainer: () throws -> DependencyContainer

    init(makeContainer: @escaping () throws -> DependencyContainer) {
        self.makeContainer = makeContainer
        load()
    }

    func retry() {
        guard container == nil else { return }
        load()
    }

    private func load() {
        do {
            container = try makeContainer()
        } catch {
            print("[Store] Could not open the store: \(error)")
        }
    }
}
