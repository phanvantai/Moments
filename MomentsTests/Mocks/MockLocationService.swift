import Foundation
@testable import Moments

final class MockLocationService: LocationServiceProtocol, @unchecked Sendable {
    var getCurrentLocationCallCount = 0
    var locationToReturn: Location?

    func getCurrentLocation() async -> Location? {
        getCurrentLocationCallCount += 1
        return locationToReturn
    }
}
