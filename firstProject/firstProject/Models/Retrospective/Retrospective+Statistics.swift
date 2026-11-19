import Foundation

extension Retrospective {
    static func inPeriod(_ items: [Retrospective], _ period: StatisticsPeriod, of date: Date, calendar: Calendar = .current) -> [Retrospective] {
        items.filter { calendar.isDate($0.date, equalTo: date, toGranularity: period.calendarComponent) }
    }

    static func emotionCounts(in items: [Retrospective]) -> [EmotionCount] {
        Emotion.allCases.map { EmotionCount(emotion: $0, count: count(of: $0, in: items)) }
    }

    static func count(of emotion: Emotion, in items: [Retrospective]) -> Int {
        items.filter { $0.emotion == emotion }.count
    }
}
