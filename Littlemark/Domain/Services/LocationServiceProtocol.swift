import Foundation

protocol LocationServiceProtocol: Sendable {
    func getCurrentLocation() async -> Location?
}
