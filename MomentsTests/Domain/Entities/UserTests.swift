import Testing
import Foundation
@testable import Moments

struct UserTests {

    @Test func test_init_withDefaults_hasCorrectValues() {
        let user = User(displayName: "Test User")

        #expect(user.displayName == "Test User")
        #expect(user.avatarPath == nil)
        #expect(user.homeLocation == nil)
    }

    @Test func test_init_withAllValues_storesCorrectly() {
        let location = Location(latitude: 10.0, longitude: 106.0)
        let user = User(
            displayName: "Test",
            avatarPath: "avatar.jpg",
            homeLocation: location
        )

        #expect(user.avatarPath == "avatar.jpg")
        #expect(user.homeLocation == location)
    }

    @Test func test_defaultUser_hasFixedId() {
        let defaultUser = User.default
        #expect(defaultUser.id == UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
        #expect(defaultUser.displayName == "Me")
    }

    @Test func test_equatable_sameUsers_areEqual() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1_000_000)
        let u1 = User(id: id, displayName: "A", createdAt: date)
        let u2 = User(id: id, displayName: "A", createdAt: date)
        #expect(u1 == u2)
    }

    @Test func test_equatable_differentUsers_areNotEqual() {
        let u1 = User(displayName: "A")
        let u2 = User(displayName: "B")
        #expect(u1 != u2)
    }
}
