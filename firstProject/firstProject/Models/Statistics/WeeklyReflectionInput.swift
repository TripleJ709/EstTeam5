import Foundation

/// AI 주간 분석에 보낼 한 주의 입력 값입니다.
///
/// 회고 본문과 함께, 앱이 미리 계산한 기록 건수와 감정 통계를 담습니다.
/// AI는 이 숫자를 다시 세지 않고 그대로 인용합니다.
/// SwiftData 모델 대신 값만 복사해 담아서 안전하게 비동기 작업으로 넘길 수 있습니다.
struct WeeklyReflectionInput: Equatable, Sendable {
    /// 그 주에 쓴 회고 한 건의 내용입니다.
    struct Entry: Equatable, Sendable {
        let date: Date
        let emotion: Emotion
        let content: String
    }

    /// 하루를 대표하는 감정입니다. 그날 가장 늦게 쓴 회고의 감정을 씁니다.
    struct DayEmotion: Equatable, Sendable {
        let date: Date
        let emotion: Emotion
    }

    /// 주를 나타내는 제목입니다. 예: `11월 15일 – 21일`
    let periodTitle: String
    /// 그 주에 쓴 회고를 오래된 순서로 정렬한 목록입니다.
    let entries: [Entry]
    /// 기록이 있는 날의 대표 감정입니다. 날짜 순서이며, 기록 없는 날은 빠집니다.
    let dailyEmotions: [DayEmotion]
    /// 감정별 기록 횟수입니다. 기록이 없는 감정도 0으로 포함합니다.
    let emotionCounts: [Emotion: Int]
    /// 가장 많이 기록한 감정입니다. 기록이 없으면 `nil`입니다.
    let topEmotion: Emotion?

    /// 전체 회고에서 한 주를 골라 분석용 입력을 만듭니다.
    ///
    /// - Parameters:
    ///   - retrospectives: 전체 회고 목록.
    ///   - anchor: 분석할 주에 속한 날짜.
    ///   - calendar: 날짜 계산에 쓸 캘린더. 기본값은 현재 캘린더입니다.
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

    /// 그 주에 쓴 회고의 건수입니다.
    var recordCount: Int { entries.count }
    /// 회고를 쓴 날의 수입니다. 같은 날 여러 건을 써도 하루로 셉니다.
    var recordedDayCount: Int { dailyEmotions.count }

    /// 가장 많이 기록한 감정의 횟수입니다. 기록이 없으면 0입니다.
    var topEmotionCount: Int {
        guard let topEmotion else { return 0 }
        return emotionCounts[topEmotion] ?? 0
    }
}
