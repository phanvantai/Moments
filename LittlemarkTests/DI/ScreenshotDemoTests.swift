import Testing
import Foundation
import SwiftData
@testable import Littlemark

@MainActor
struct ScreenshotDemoTests {
    private let now = Date(timeIntervalSince1970: 1_793_361_600)

    private func makeTempDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("ScreenshotDemoTests_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    // MARK: - Moments

    @Test func test_moments_returnsRequestedCount() {
        let moments = ScreenshotDemo.moments(count: 50, language: .english, now: now)

        #expect(moments.count == 50)
        #expect(Set(moments.map(\.id)).count == 50)
    }

    @Test func test_moments_allHaveMediaOrVoice() {
        let moments = ScreenshotDemo.moments(count: 30, language: .english, now: now)

        #expect(moments.allSatisfy { !$0.mediaItems.isEmpty || $0.voiceNote != nil })
    }

    @Test func test_moments_areInThePast_newestFirst() {
        let moments = ScreenshotDemo.moments(count: 30, language: .english, now: now)
        let dates = moments.map(\.createdAt)

        #expect(dates.allSatisfy { $0 <= now })
        #expect(dates == dates.sorted(by: >))
    }

    @Test(arguments: [AppLanguage.english, .vietnamese, .japanese])
    func test_moments_textFollowsLanguage(language: AppLanguage) {
        let english = ScreenshotDemo.moments(count: 1, language: .english, now: now)
        let localized = ScreenshotDemo.moments(count: 1, language: language, now: now)

        #expect(localized.first?.text?.isEmpty == false)
        #expect((localized.first?.text == english.first?.text) == (language == .english))
    }

    // MARK: - Media

    @Test func test_copyMedia_copiesImagesIntoMediaFolder() throws {
        let source = try makeTempDirectory()
        let documents = try makeTempDirectory()
        defer {
            try? FileManager.default.removeItem(at: source)
            try? FileManager.default.removeItem(at: documents)
        }
        try Data([0x01]).write(to: source.appendingPathComponent("picsum-1025.jpg"))
        try Data([0x02]).write(to: source.appendingPathComponent("notes.txt"))

        try ScreenshotDemo.copyMedia(from: source, toDocuments: documents)

        let copied = try FileManager.default.contentsOfDirectory(atPath: documents.appendingPathComponent("Media").path)
        #expect(copied == ["demo-picsum-1025.jpg"])
    }

    // MARK: - Store

    @Test func test_makeModelContainer_seedsInMemoryStore() async throws {
        let container = try ScreenshotDemo.makeModelContainer(count: 25, language: .english, now: now)

        let fetched = try await MomentRepository(modelContainer: container).fetchAll()
        #expect(fetched.count == 25)
    }
}
