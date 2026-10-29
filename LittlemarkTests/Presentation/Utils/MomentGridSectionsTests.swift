import Testing
import Foundation
@testable import Littlemark

@MainActor
struct MomentGridSectionsTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let locale = Locale(identifier: "en_US")
    private let labels = MomentGridSections.Labels(today: "Today", yesterday: "Yesterday", thisWeek: "This Week")

    /// 2026-10-30 12:00 UTC
    private let now = Date(timeIntervalSince1970: 1_793_361_600)

    private func moment(daysAgo: Int) -> Moment {
        MockMomentFactory.makeMoment(createdAt: now.addingTimeInterval(TimeInterval(-daysAgo * 86_400)))
    }

    private func make(_ moments: [Moment]) -> [MomentGridSections.Section] {
        MomentGridSections.make(from: moments, now: now, calendar: calendar, locale: locale, labels: labels)
    }

    @Test func test_make_empty_returnsNoSections() {
        #expect(make([]).isEmpty)
    }

    @Test func test_make_oldestFirstInput_keepsNewestSectionLast() {
        let sections = make([moment(daysAgo: 40), moment(daysAgo: 3), moment(daysAgo: 1), moment(daysAgo: 0)])

        #expect(sections.map(\.title) == ["September 2026", "This Week", "Yesterday", "Today"])
    }

    @Test func test_make_groupsConsecutiveMomentsWithSameLabel() {
        let a = moment(daysAgo: 0)
        let b = moment(daysAgo: 0)

        let sections = make([a, b])

        #expect(sections.count == 1)
        #expect(sections.first?.moments.map(\.id) == [a.id, b.id])
    }

    @Test func test_make_sectionIdsAreUnique() {
        let sections = make([moment(daysAgo: 40), moment(daysAgo: 70), moment(daysAgo: 0)])

        #expect(Set(sections.map(\.id)).count == sections.count)
    }

    @Test func test_make_monthTitle_usesGivenLocale() {
        let sections = MomentGridSections.make(
            from: [moment(daysAgo: 40)],
            now: now,
            calendar: calendar,
            locale: Locale(identifier: "vi_VN"),
            labels: labels
        )

        #expect(sections.first?.title.lowercased().contains("9") == true)
        #expect(sections.first?.title.contains("2026") == true)
    }
}
