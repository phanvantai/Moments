import Foundation

struct User: Equatable, Hashable, Identifiable, Sendable {
    let id: UUID
    var displayName: String
    var avatarPath: String?
    let createdAt: Date
    var homeLocation: Location?

    init(
        id: UUID = UUID(),
        displayName: String,
        avatarPath: String? = nil,
        createdAt: Date = Date(),
        homeLocation: Location? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarPath = avatarPath
        self.createdAt = createdAt
        self.homeLocation = homeLocation
    }

    static let `default` = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        displayName: "Me",
        createdAt: Date(timeIntervalSince1970: 0)
    )
}
