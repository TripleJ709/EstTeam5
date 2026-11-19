import Foundation

extension Retrospective {
    static func latest(in items: [Retrospective], on date: Date, calendar: Calendar = .current) -> Retrospective? {
        let sameDayItems = items.filter { calendar.isDate($0.date, inSameDayAs: date) }
        guard var latest = sameDayItems.first else { return nil }

        for item in sameDayItems {
            if item.createdAt > latest.createdAt {
                latest = item
            }
        }
        return latest
    }

    static func topEmotion(in items: [Retrospective]) -> Emotion? {
        var top: Emotion?
        var topCount = 0

        for emotion in Emotion.allCases {
            let count = Retrospective.count(of: emotion, in: items)
            if count > topCount {
                top = emotion
                topCount = count
            }
        }
        return top
    }

    static func monthSummary(of items: [Retrospective], month: Date, calendar: Calendar = .current) -> String {
        let monthItems = inPeriod(items, .month, of: month, calendar: calendar)
        guard let top = topEmotion(in: monthItems) else { return "첫 회고를 남기면 달력에 색이 채워져요" }
        return "이번 달은 \(top.displayName)\(top.subjectParticle) 가장 많았어요 · \(monthItems.count)개의 기록"
    }
}
