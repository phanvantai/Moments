#if DEBUG
import Foundation
import SwiftData

/// Sample moments for App Store and landing page screenshots (DEBUG builds only).
///
/// ```
/// SIMCTL_CHILD_SCREENSHOT_DEMO_MEDIA="$PWD/screenshots/demo-media" \
///   xcrun simctl launch <udid> com.randomtech.littlemark \
///   -ScreenshotDemo -hasCompletedOnboarding YES -appLanguage vi -ScreenshotDemoCount 16
/// ```
/// The app opens an in-memory store filled with these moments; the real store is never opened.
/// Photos come from `SCREENSHOT_DEMO_MEDIA` (a folder on the Mac) and are copied into
/// Documents/Media, so they are never bundled into the app.
@MainActor
enum ScreenshotDemo {
    nonisolated static let launchArgument = "-ScreenshotDemo"
    static let mediaDirectoryKey = "SCREENSHOT_DEMO_MEDIA"
    static let countKey = "ScreenshotDemoCount"

    nonisolated static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains(launchArgument)
    }

    static func makeDependencyContainer() throws -> DependencyContainer {
        if let path = ProcessInfo.processInfo.environment[mediaDirectoryKey] {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            try copyMedia(from: URL(fileURLWithPath: path), toDocuments: documents)
        }
        let requested = UserDefaults.standard.integer(forKey: countKey)
        let container = try makeModelContainer(
            count: requested > 0 ? requested : samples.count,
            language: LanguageManager.shared.currentLanguage
        )
        return DependencyContainer(modelContainer: container)
    }

    static func makeModelContainer(count: Int, language: AppLanguage, now: Date = .now) throws -> ModelContainer {
        let container = try ModelContainerFactory.make(storage: .inMemory)
        let context = ModelContext(container)
        for moment in moments(count: count, language: language, now: now) {
            context.insert(MomentMapper.toSDModel(moment))
        }
        try context.save()
        return container
    }

    static func copyMedia(from source: URL, toDocuments documents: URL) throws {
        let fileManager = FileManager.default
        let mediaDirectory = documents.appendingPathComponent(MediaFileService.mediaDirectoryName)
        try fileManager.createDirectory(at: mediaDirectory, withIntermediateDirectories: true)
        for name in try fileManager.contentsOfDirectory(atPath: source.path) where name.hasSuffix(".jpg") {
            let destination = mediaDirectory.appendingPathComponent("demo-\(name)")
            try? fileManager.removeItem(at: destination)
            try fileManager.copyItem(at: source.appendingPathComponent(name), to: destination)
        }
    }

    /// Newest first. Beyond the samples, the list repeats them a month further back each round,
    /// which gives enough moments to scroll through several pages.
    static func moments(count: Int, language: AppLanguage, now: Date = .now) -> [Moment] {
        (0..<count).map { index in
            let sample = samples[index % samples.count]
            let round = index / samples.count
            let createdAt = now.addingTimeInterval(-(sample.hoursAgo + Double(round) * 24 * 31) * 3600)
            return sample.moment(language: language, createdAt: createdAt)
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Samples

    private struct Sample {
        let photos: [String]
        let hoursAgo: Double
        let text: [AppLanguage: String]
        let categoryKeys: [String]
        let place: (latitude: Double, longitude: Double, names: [AppLanguage: String])
        let weather: (icon: String, temperature: Double, conditions: [AppLanguage: String])
        var voice: (duration: TimeInterval, transcripts: [AppLanguage: String])?

        func moment(language: AppLanguage, createdAt: Date) -> Moment {
            let momentId = UUID()
            return Moment(
                id: momentId,
                userId: User.default.id,
                createdAt: createdAt,
                updatedAt: createdAt,
                text: text[language],
                mediaItems: photos.enumerated().map { index, photo in
                    MediaItem(
                        momentId: momentId,
                        type: .photo,
                        filePath: "\(MediaFileService.mediaDirectoryName)/demo-\(photo).jpg",
                        width: 900,
                        height: 1200,
                        sortOrder: index
                    )
                },
                voiceNote: voice.map {
                    VoiceNote(filePath: "\(MediaFileService.voiceDirectoryName)/demo.m4a", duration: $0.duration, transcript: $0.transcripts[language])
                },
                location: Location(latitude: place.latitude, longitude: place.longitude, name: place.names[language]),
                categories: categoryKeys.compactMap(MomentCategory.find(byKey:)),
                weather: Weather(condition: weather.conditions[language] ?? "", temperature: weather.temperature, icon: weather.icon)
            )
        }
    }

    private static let home = (latitude: 21.0285, longitude: 105.8542, names: [AppLanguage.english: "Home", .vietnamese: "Nhà", .japanese: "自宅"])
    private static let hanoi = (latitude: 21.0287, longitude: 105.8524, names: [AppLanguage.english: "Hoan Kiem, Hanoi", .vietnamese: "Hoàn Kiếm, Hà Nội", .japanese: "ホアンキエム、ハノイ"])
    private static let park = (latitude: 21.0368, longitude: 105.8342, names: [AppLanguage.english: "Thu Le Park", .vietnamese: "Công viên Thủ Lệ", .japanese: "トゥーレ公園"])
    private static let lake = (latitude: 51.4254, longitude: -116.1773, names: [AppLanguage.english: "Lake Louise, Canada", .vietnamese: "Hồ Louise, Canada", .japanese: "レイク・ルイーズ、カナダ"])
    private static let iceland = (latitude: 63.5321, longitude: -19.5114, names: [AppLanguage.english: "Skógafoss, Iceland", .vietnamese: "Skógafoss, Iceland", .japanese: "スコゥガフォス、アイスランド"])
    private static let bavaria = (latitude: 47.5576, longitude: 10.7498, names: [AppLanguage.english: "Neuschwanstein, Germany", .vietnamese: "Neuschwanstein, Đức", .japanese: "ノイシュヴァンシュタイン城、ドイツ"])
    private static let dalat = (latitude: 11.9404, longitude: 108.4583, names: [AppLanguage.english: "Da Lat", .vietnamese: "Đà Lạt", .japanese: "ダラット"])

    private static let cloudy = (icon: "cloud.fill", temperature: 24.0, conditions: [AppLanguage.english: "Cloudy", .vietnamese: "Nhiều mây", .japanese: "くもり"])
    private static let sunny = (icon: "sun.max.fill", temperature: 29.0, conditions: [AppLanguage.english: "Sunny", .vietnamese: "Nắng", .japanese: "晴れ"])
    private static let partlyCloudy = (icon: "cloud.sun.fill", temperature: 12.0, conditions: [AppLanguage.english: "Partly Cloudy", .vietnamese: "Có mây", .japanese: "晴れ時々くもり"])
    private static let cool = (icon: "cloud.sun.fill", temperature: 18.0, conditions: [AppLanguage.english: "Mostly Clear", .vietnamese: "Trời quang", .japanese: "おおむね晴れ"])
    private static let drizzle = (icon: "cloud.drizzle.fill", temperature: 9.0, conditions: [AppLanguage.english: "Drizzle", .vietnamese: "Mưa phùn", .japanese: "霧雨"])

    private static let samples: [Sample] = [
        Sample(
            photos: ["picsum-1025"], hoursAgo: 2,
            text: [.english: "Bean refused to leave the blanket fort this morning.",
                   .vietnamese: "Sáng nay Bean nhất quyết không chịu chui ra khỏi chăn.",
                   .japanese: "今朝、ビーンは毛布から出ようとしなかった。"],
            categoryKeys: ["daily", "play"], place: home, weather: cloudy
        ),
        Sample(
            photos: ["picsum-431"], hoursAgo: 27,
            text: [.english: "First coffee at the new café on our street.",
                   .vietnamese: "Ly cà phê đầu tiên ở quán mới đầu ngõ.",
                   .japanese: "近所の新しいカフェで初めてのコーヒー。"],
            categoryKeys: ["first-time", "food"], place: hanoi, weather: sunny
        ),
        Sample(
            photos: ["picsum-237"], hoursAgo: 75,
            text: [.english: "Meet Mochi! Our first night together.",
                   .vietnamese: "Chào Mochi! Đêm đầu tiên cả nhà có thêm một thành viên.",
                   .japanese: "モチがやってきた！一緒に過ごす初めての夜。"],
            categoryKeys: ["first-time", "family"], place: home, weather: cloudy,
            voice: (18, [.english: "She fell asleep on my feet after five minutes.",
                         .vietnamese: "Mới năm phút mà em nó đã ngủ gục trên chân mình rồi.",
                         .japanese: "5分で私の足の上で寝てしまった。"])
        ),
        Sample(
            photos: ["picsum-1011", "picsum-1015"], hoursAgo: 130,
            text: [.english: "Paddled across the lake before sunrise. So quiet.",
                   .vietnamese: "Chèo thuyền qua hồ trước lúc bình minh. Yên tĩnh lạ thường.",
                   .japanese: "日の出前に湖をカヌーで渡った。とても静か。"],
            categoryKeys: ["travel", "outdoor"], place: lake, weather: partlyCloudy
        ),
        Sample(
            photos: ["picsum-488", "picsum-429"], hoursAgo: 150,
            text: [.english: "Sunday lunch with the whole family.",
                   .vietnamese: "Bữa trưa Chủ nhật đông đủ cả nhà.",
                   .japanese: "家族みんなで日曜日のランチ。"],
            categoryKeys: ["family", "food"], place: home, weather: sunny
        ),
        Sample(
            photos: ["picsum-1035", "picsum-1036"], hoursAgo: 290,
            text: [.english: "We made it to the waterfall! Rainbow included.",
                   .vietnamese: "Cuối cùng cũng tới được thác! Còn có cả cầu vồng.",
                   .japanese: "ついに滝に到着！虹のおまけつき。"],
            categoryKeys: ["travel", "milestone"], place: iceland, weather: drizzle
        ),
        Sample(
            photos: ["picsum-1012"], hoursAgo: 380,
            text: [.english: "Lazy afternoon in the park with Mochi.",
                   .vietnamese: "Buổi chiều thong thả ở công viên cùng Mochi.",
                   .japanese: "モチと公園でのんびり午後。"],
            categoryKeys: ["outdoor", "play"], place: park, weather: sunny
        ),
        Sample(
            photos: ["picsum-1073"], hoursAgo: 520,
            text: [.english: "Finished my 20th book this year.",
                   .vietnamese: "Đọc xong cuốn sách thứ 20 trong năm.",
                   .japanese: "今年20冊目の本を読み終えた。"],
            categoryKeys: ["milestone", "learn"], place: home, weather: cloudy
        ),
        Sample(
            photos: ["picsum-1060", "picsum-225"], hoursAgo: 700,
            text: [.english: "Learning pour-over at Grandpa's. He says I'm too impatient.",
                   .vietnamese: "Học pha cà phê phin ở nhà ông. Ông bảo mình nóng vội quá.",
                   .japanese: "おじいちゃんの家でハンドドリップを習った。せっかちだと言われた。"],
            categoryKeys: ["family", "learn"], place: dalat, weather: cool
        ),
        Sample(
            photos: ["picsum-1040", "picsum-1043"], hoursAgo: 1_080,
            text: [.english: "A real fairytale castle. Worth every step uphill.",
                   .vietnamese: "Lâu đài cổ tích ngoài đời thật. Leo dốc mỏi chân nhưng đáng.",
                   .japanese: "本物のおとぎ話のお城。坂道を登った甲斐があった。"],
            categoryKeys: ["travel"], place: bavaria, weather: partlyCloudy
        ),
        Sample(
            photos: ["picsum-1003"], hoursAgo: 1_450,
            text: [.english: "A deer walked right up to us!",
                   .vietnamese: "Một chú nai đi thẳng tới chỗ tụi mình!",
                   .japanese: "シカがすぐそばまで来てくれた！"],
            categoryKeys: ["outdoor", "first-time"], place: dalat, weather: cool
        ),
        Sample(
            photos: ["picsum-883"], hoursAgo: 1_800,
            text: [.english: "Cold air, clear head.",
                   .vietnamese: "Không khí lạnh, đầu óc nhẹ tênh.",
                   .japanese: "冷たい空気で頭がすっきり。"],
            categoryKeys: ["outdoor"], place: lake, weather: partlyCloudy
        ),
    ]
}
#endif
