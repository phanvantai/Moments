import Foundation

protocol MomentRepositoryProtocol: Sendable {
    func create(_ moment: Moment) async throws
    func fetchAll() async throws -> [Moment]
    func fetch(byId id: UUID) async throws -> Moment?
    func update(_ moment: Moment) async throws
    func delete(byId id: UUID) async throws
}
