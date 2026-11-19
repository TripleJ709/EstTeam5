import Foundation

/// `Retrospective`의 통계 집계 기능을 제공합니다.
extension Retrospective {
    /// 지정한 기간 단위로 기준 날짜와 같은 기간에 속한 회고만 반환합니다.
    ///
    /// - Parameters:
    ///   - items: 필터링할 회고 목록입니다.
    ///   - period: 기간 단위(주간 또는 월간)입니다.
    ///   - date: 기준 날짜입니다.
    ///   - calendar: 비교에 사용할 캘린더입니다. 기본값은 `.current`입니다.
    /// - Returns: 같은 기간에 속한 회고 배열입니다.
    static func inPeriod(_ items: [Retrospective], _ period: StatisticsPeriod, of date: Date, calendar: Calendar = .current) -> [Retrospective] {
        items.filter { calendar.isDate($0.date, equalTo: date, toGranularity: period.calendarComponent) }
    }

    /// 모든 감정에 대해 기록 횟수를 계산합니다.
    ///
    /// - Parameter items: 집계할 회고 목록입니다.
    /// - Returns: `Emotion.allCases` 순서의 `EmotionCount` 배열입니다. 기록이 없는 감정도 횟수 0으로 포함됩니다.
    static func emotionCounts(in items: [Retrospective]) -> [EmotionCount] {
        Emotion.allCases.map { EmotionCount(emotion: $0, count: count(of: $0, in: items)) }
    }

    /// 특정 감정으로 기록된 회고의 수를 반환합니다.
    ///
    /// - Parameters:
    ///   - emotion: 세려는 감정입니다.
    ///   - items: 집계할 회고 목록입니다.
    /// - Returns: 해당 감정의 회고 수입니다.
    static func count(of emotion: Emotion, in items: [Retrospective]) -> Int {
        items.filter { $0.emotion == emotion }.count
    }
}
