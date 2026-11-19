import Foundation

/// 주간 분석에 전달할 한 주 분량의 회고 데이터입니다.
///
/// 기준 날짜가 속한 주의 회고를 모아 기록 목록, 요일별 감정, 감정별 횟수, 대표 감정을 계산해 담습니다.
struct WeeklyReflectionInput: Equatable, Sendable {
    /// 회고 한 건의 날짜, 감정, 본문입니다.
    struct Entry: Equatable, Sendable {
        /// 회고 날짜입니다.
        let date: Date
        /// 회고에 기록한 감정입니다.
        let emotion: Emotion
        /// 회고 본문입니다.
        let content: String
    }

    /// 하루의 대표 감정입니다.
    struct DayEmotion: Equatable, Sendable {
        /// 해당 날짜입니다.
        let date: Date
        /// 그날 가장 늦게 작성된 회고의 감정입니다.
        let emotion: Emotion
    }

    /// 기간 제목입니다. `StatisticsPeriod.week`의 `title(of:calendar:)` 결과입니다.
    let periodTitle: String
    /// 해당 주의 회고 목록입니다. 날짜 순, 같은 날짜면 작성 시각 순으로 정렬됩니다.
    let entries: [Entry]
    /// 기록이 있는 날의 대표 감정 목록입니다. 주의 날짜 순서를 따릅니다.
    let dailyEmotions: [DayEmotion]
    /// 모든 감정별 기록 횟수입니다. 기록이 없는 감정은 0으로 들어 있습니다.
    let emotionCounts: [Emotion: Int]
    /// 가장 많이 기록된 감정입니다. 기록이 없으면 `nil`입니다.
    let topEmotion: Emotion?

    /// 기준 날짜가 속한 주의 회고로 입력 값을 만듭니다.
    ///
    /// - Parameters:
    ///   - retrospectives: 전체 회고 목록입니다. 이 중 해당 주의 회고만 사용합니다.
    ///   - anchor: 주를 결정하는 기준 날짜입니다.
    ///   - calendar: 주 계산에 사용할 캘린더입니다. 기본값은 `.current`입니다.
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

    /// 해당 주의 기록 건수입니다.
    var recordCount: Int { entries.count }
    /// 기록이 있는 날의 수입니다.
    var recordedDayCount: Int { dailyEmotions.count }

    /// 대표 감정의 기록 횟수입니다. 대표 감정이 없으면 0입니다.
    var topEmotionCount: Int {
        guard let topEmotion else { return 0 }
        return emotionCounts[topEmotion] ?? 0
    }
}
