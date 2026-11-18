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
        let counts = Retrospective.emotionCounts(in: items)

        periodTitle = period.title(of: anchor, calendar: calendar)
        entries = items
            .sorted { ($0.date, $0.createdAt) < ($1.date, $1.createdAt) }
            .map { Entry(date: $0.date, emotion: $0.emotion, content: $0.content) }
        dailyEmotions = period.days(of: anchor, calendar: calendar).compactMap { day in
            Retrospective.latest(in: items, on: day, calendar: calendar)
                .map { DayEmotion(date: day, emotion: $0.emotion) }
        }
        emotionCounts = Dictionary(uniqueKeysWithValues: counts.map { ($0.emotion, $0.count) })
        topEmotion = Retrospective.topEmotion(in: items)
    }

    var recordCount: Int { entries.count }
    var recordedDayCount: Int { dailyEmotions.count }
    var topEmotionCount: Int { topEmotion.flatMap { emotionCounts[$0] } ?? 0 }
}
