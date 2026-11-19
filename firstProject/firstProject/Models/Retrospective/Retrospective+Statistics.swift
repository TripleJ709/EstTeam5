import Foundation

extension Retrospective {
    static func inPeriod(
        _ items: [Retrospective],
        _ period: StatisticsPeriod,
        of date: Date,
        calendar: Calendar = .current
    ) -> [Retrospective] {
        switch period {
        case .month:
            inMonth(items, of: date, calendar: calendar)
        case .week:
            items.filter { calendar.isDate($0.date, equalTo: date, toGranularity: period.calendarComponent) }
        }
    }

    static func emotionCounts(in items: [Retrospective]) -> [(emotion: Emotion, count: Int)] {
        let counts = Dictionary(grouping: items, by: \.emotion).mapValues(\.count)
        return Emotion.allCases.map { ($0, counts[$0] ?? 0) }
    }

    static func count(of emotion: Emotion, in items: [Retrospective]) -> Int {
        items.filter { $0.emotion == emotion }.count
    }
}
