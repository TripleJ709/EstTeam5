import Foundation

extension Retrospective {
    static func inMonth(_ items: [Retrospective], of month: Date, calendar: Calendar = .current) -> [Retrospective] {
        items.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }

    static func latest(in items: [Retrospective], on date: Date, calendar: Calendar = .current) -> Retrospective? {
        items.filter { calendar.isDate($0.date, inSameDayAs: date) }.max { $0.createdAt < $1.createdAt }
    }

    static func topEmotion(in items: [Retrospective]) -> Emotion? {
        guard !items.isEmpty else { return nil }
        let counts = Dictionary(grouping: items, by: \.emotion).mapValues(\.count)
        return Emotion.allCases.max { (counts[$0] ?? 0) < (counts[$1] ?? 0) }
    }

    static func monthSummary(of items: [Retrospective], month: Date, calendar: Calendar = .current) -> String {
        let monthItems = inMonth(items, of: month, calendar: calendar)
        guard let top = topEmotion(in: monthItems) else { return "첫 회고를 남기면 달력에 색이 채워져요" }
        return "이번 달은 \(top.displayName)\(top.subjectParticle) 가장 많았어요 · \(monthItems.count)개의 기록"
    }
}
