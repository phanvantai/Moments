import Foundation
@testable import Littlemark

final class MockLocationService: LocationServiceProtocol, @unchecked Sendable {
    var getCurrentLocationCallCount = 0
    var locationToReturn: Location?

    func getCurrentLocation() async -> Location? {
        getCurrentLocationCallCount += 1
        return locationToReturn
    }
}
