import Foundation

/// Groups moments for the grid. Input and output are oldest-first, so the newest
/// section ("Today") is at the bottom, like the Photos library.
enum MomentGridSections {
    struct Section: Identifiable {
        let id: String
        let title: String
        let moments: [Moment]
    }

    struct Labels {
        let today: String
        let yesterday: String
        let thisWeek: String
    }

    static func make(
        from moments: [Moment],
        now: Date = Date(),
        calendar: Calendar = .current,
        locale: Locale,
        labels: Labels
    ) -> [Section] {
        let monthFormatter = DateFormatter()
        monthFormatter.calendar = calendar
        monthFormatter.locale = locale
        monthFormatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")

        var sections: [Section] = []
        var currentTitle: String?
        var currentMoments: [Moment] = []

        func closeSection() {
            guard let currentTitle, !currentMoments.isEmpty else { return }
            sections.append(Section(id: "\(sections.count)-\(currentTitle)", title: currentTitle, moments: currentMoments))
        }

        for moment in moments {
            let title = title(for: moment.createdAt, now: now, calendar: calendar, monthFormatter: monthFormatter, labels: labels)
            if title != currentTitle {
                closeSection()
                currentTitle = title
                currentMoments = []
            }
            currentMoments.append(moment)
        }
        closeSection()
        return sections
    }

    private static func title(
        for date: Date,
        now: Date,
        calendar: Calendar,
        monthFormatter: DateFormatter,
        labels: Labels
    ) -> String {
        if calendar.isDate(date, inSameDayAs: now) {
            return labels.today
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return labels.yesterday
        }
        if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now), date >= weekAgo {
            return labels.thisWeek
        }
        return monthFormatter.string(from: date)
    }
}
