import Testing
import Foundation
import SwiftData
@testable import Littlemark

@MainActor
struct AppLaunchViewModelTests {

    private struct StoreError: Error {}

    private func makeContainer() throws -> DependencyContainer {
        DependencyContainer(modelContainer: try ModelContainerFactory.make(storage: .inMemory))
    }

    // MARK: - Init

    @Test func test_init_factorySucceeds_isReady() {
        let sut = AppLaunchViewModel(makeContainer: makeContainer)

        #expect(sut.container != nil)
        #expect(!sut.didFailToLoadStore)
    }

    @Test func test_init_factoryThrows_failsWithoutCrashing() {
        let sut = AppLaunchViewModel(makeContainer: { throw StoreError() })

        #expect(sut.container == nil)
        #expect(sut.didFailToLoadStore)
    }

    // MARK: - Retry

    @Test func test_retry_afterFailure_factorySucceeds_isReady() {
        var attempts = 0
        let sut = AppLaunchViewModel(makeContainer: {
            attempts += 1
            if attempts == 1 { throw StoreError() }
            return try makeContainer()
        })

        sut.retry()

        #expect(attempts == 2)
        #expect(sut.container != nil)
        #expect(!sut.didFailToLoadStore)
    }

    @Test func test_retry_whenReady_doesNotRecreateContainer() {
        var attempts = 0
        let sut = AppLaunchViewModel(makeContainer: {
            attempts += 1
            return try makeContainer()
        })

        sut.retry()

        #expect(attempts == 1)
    }
}
