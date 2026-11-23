import Foundation

/// 회고 통계 계산 기능입니다.
extension Retrospective {
    /// 기준 날짜와 같은 기간(주 또는 월)에 속한 회고만 골라 반환합니다.
    ///
    /// - Parameters:
    ///   - items: 대상 회고 목록입니다.
    ///   - period: 기간 단위입니다.
    ///   - date: 기준 날짜입니다.
    ///   - calendar: 계산에 사용할 달력입니다. 기본값은 `.current`입니다.
    /// - Returns: 해당 기간에 속한 회고 배열입니다.
    static func inPeriod(_ items: [Retrospective], _ period: StatisticsPeriod, of date: Date, calendar: Calendar = .current) -> [Retrospective] {
        items.filter { calendar.isDate($0.date, equalTo: date, toGranularity: period.calendarComponent) }
    }

    /// 모든 감정에 대해 기록 횟수를 계산해 반환합니다.
    ///
    /// - Parameter items: 대상 회고 목록입니다.
    /// - Returns: `Emotion.allCases` 순서의 감정별 횟수 배열입니다.
    static func emotionCounts(in items: [Retrospective]) -> [EmotionCount] {
        Emotion.allCases.map { EmotionCount(emotion: $0, count: count(of: $0, in: items)) }
    }

    /// 특정 감정의 회고 개수를 반환합니다.
    ///
    /// - Parameters:
    ///   - emotion: 개수를 셀 감정입니다.
    ///   - items: 대상 회고 목록입니다.
    /// - Returns: 해당 감정의 회고 개수입니다.
    static func count(of emotion: Emotion, in items: [Retrospective]) -> Int {
        items.filter { $0.emotion == emotion }.count
    }
}
