import Foundation

enum StatisticsPeriod: String, CaseIterable, Identifiable {
    case week = "주간"
    case month = "월간"

    var id: String { rawValue }

    private static let locale = Locale(identifier: "ko_KR")

    var calendarComponent: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        }
    }

    var recordCountLabel: String {
        switch self {
        case .week: "이번 주 기록"
        case .month: "이번 달 기록"
        }
    }

    var emptyTitle: String {
        switch self {
        case .week: "이 주에는 기록이 없어요"
        case .month: "이 달에는 기록이 없어요"
        }
    }

    var feedbackTitle: String {
        switch self {
        case .week: "이번 주의 한마디"
        case .month: "이번 달의 한마디"
        }
    }

    func feedback(for emotion: Emotion) -> String {
        switch self {
        case .week: emotion.weeklyFeedback
        case .month: emotion.monthlyFeedback
        }
    }

    func days(of anchor: Date, calendar: Calendar = .current) -> [Date] {
        guard let interval = calendar.dateInterval(of: calendarComponent, for: anchor) else { return [] }
        var result: [Date] = []
        var cursor = interval.start
        while cursor < interval.end {
            result.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    func title(of anchor: Date, calendar: Calendar = .current) -> String {
        switch self {
        case .month:
            return anchor.formatted(.dateTime.year().month(.wide).locale(Self.locale))
        case .week:
            let periodDays = days(of: anchor, calendar: calendar)
            guard let first = periodDays.first, let last = periodDays.last else { return "" }
            let startStyle = Date.FormatStyle.dateTime.month().day().locale(Self.locale)
            let endStyle = calendar.isDate(first, equalTo: last, toGranularity: .month)
                ? Date.FormatStyle.dateTime.day().locale(Self.locale)
                : startStyle
            return "\(first.formatted(startStyle)) – \(last.formatted(endStyle))"
        }
    }

    func moved(_ anchor: Date, by value: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: calendarComponent, value: value, to: anchor) ?? anchor
    }
}
