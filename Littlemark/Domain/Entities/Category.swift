import Foundation

struct MomentCategory: Equatable, Hashable, Identifiable, Sendable {
    let key: String
    let label: String
    let emoji: String
    let colorKey: String
    let keywords: [String]

    var id: String { key }

    init(
        key: String,
        label: String,
        emoji: String,
        colorKey: String,
        keywords: [String]
    ) {
        self.key = key
        self.label = label
        self.emoji = emoji
        self.colorKey = colorKey
        self.keywords = keywords
    }
}

extension MomentCategory {
    static let predefined: [MomentCategory] = [
        MomentCategory(
            key: "first-time",
            label: "Lần đầu tiên",
            emoji: "⭐",
            colorKey: "categoryFirstTime",
            keywords: ["đầu tiên", "lần đầu", "biết"]
        ),
        MomentCategory(
            key: "milestone",
            label: "Cột mốc",
            emoji: "🏆",
            colorKey: "categoryMilestone",
            keywords: ["tuổi", "sinh nhật", "tháng"]
        ),
        MomentCategory(
            key: "daily",
            label: "Hàng ngày",
            emoji: "☀️",
            colorKey: "categoryDaily",
            keywords: []
        ),
        MomentCategory(
            key: "outdoor",
            label: "Ngoài trời",
            emoji: "🌳",
            colorKey: "categoryOutdoor",
            keywords: ["công viên", "biển", "ngoài trời"]
        ),
        MomentCategory(
            key: "family",
            label: "Gia đình",
            emoji: "👨‍👩‍👧",
            colorKey: "categoryFamily",
            keywords: ["ông", "bà", "ba", "mẹ", "gia đình"]
        ),
        MomentCategory(
            key: "health",
            label: "Sức khoẻ",
            emoji: "🏥",
            colorKey: "categoryHealth",
            keywords: ["khám", "tiêm", "ốm", "bệnh viện"]
        ),
        MomentCategory(
            key: "travel",
            label: "Du lịch",
            emoji: "✈️",
            colorKey: "categoryTravel",
            keywords: ["du lịch", "trip", "chuyến đi"]
        ),
        MomentCategory(
            key: "food",
            label: "Ăn uống",
            emoji: "🍼",
            colorKey: "categoryFood",
            keywords: ["ăn", "sữa", "uống", "nhà hàng"]
        ),
        MomentCategory(
            key: "play",
            label: "Vui chơi",
            emoji: "🎮",
            colorKey: "categoryPlay",
            keywords: ["chơi", "đồ chơi", "vui"]
        ),
        MomentCategory(
            key: "learn",
            label: "Học hỏi",
            emoji: "📚",
            colorKey: "categoryLearn",
            keywords: ["nói", "đọc", "viết", "học", "biết"]
        ),
    ]

    static func find(byKey key: String) -> MomentCategory? {
        predefined.first { $0.key == key }
    }
}
