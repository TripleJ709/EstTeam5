import Foundation

struct WeeklyReflectionInput: Equatable, Sendable {
    struct Entry: Equatable, Sendable {
        let date: Date
        let emotion: Emotion
        let content: String
    }

    struct DayEmotion: Equatable, Sendable {
        let date: Date
        let emotion: Emotion
    }

    let periodTitle: String
    let entries: [Entry]
    let dailyEmotions: [DayEmotion]
    let emotionCounts: [Emotion: Int]
    let topEmotion: Emotion?

    init(retrospectives: [Retrospective], weekOf anchor: Date, calendar: Calendar = .current) {
        let period = StatisticsPeriod.week
        let items = Retrospective.inPeriod(retrospectives, period, of: anchor, calendar: calendar)

        let sortedItems = items.sorted { first, second in
            if first.date != second.date {
                return first.date < second.date
            }
            return first.createdAt < second.createdAt
        }

        var dailyEmotions: [DayEmotion] = []
        for day in period.days(of: anchor, calendar: calendar) {
            if let latest = Retrospective.latest(in: items, on: day, calendar: calendar) {
                dailyEmotions.append(DayEmotion(date: day, emotion: latest.emotion))
            }
        }

        var emotionCounts: [Emotion: Int] = [:]
        for emotion in Emotion.allCases {
            emotionCounts[emotion] = Retrospective.count(of: emotion, in: items)
        }

        self.periodTitle = period.title(of: anchor, calendar: calendar)
        self.entries = sortedItems.map { Entry(date: $0.date, emotion: $0.emotion, content: $0.content) }
        self.dailyEmotions = dailyEmotions
        self.emotionCounts = emotionCounts
        self.topEmotion = Retrospective.topEmotion(in: items)
    }

    var recordCount: Int { entries.count }
    var recordedDayCount: Int { dailyEmotions.count }

    var topEmotionCount: Int {
        guard let topEmotion else { return 0 }
        return emotionCounts[topEmotion] ?? 0
    }
}
