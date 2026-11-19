import Foundation

extension Retrospective {
    /// 기준 날짜가 속한 주 또는 달의 회고만 골라냅니다.
    ///
    /// - Parameters:
    ///   - items: 전체 회고 목록.
    ///   - period: 주간 또는 월간.
    ///   - date: 기준 날짜.
    ///   - calendar: 날짜 비교에 쓸 캘린더. 기본값은 현재 캘린더입니다.
    /// - Returns: 해당 기간에 쓴 회고.
    static func inPeriod(_ items: [Retrospective], _ period: StatisticsPeriod, of date: Date, calendar: Calendar = .current) -> [Retrospective] {
        items.filter { calendar.isDate($0.date, equalTo: date, toGranularity: period.calendarComponent) }
    }

    /// 감정별 기록 횟수를 셉니다.
    ///
    /// 기록이 없는 감정도 0회로 포함해, 항상 7개를 `Emotion.allCases` 순서로 돌려줍니다.
    ///
    /// - Parameter items: 집계할 회고 목록.
    /// - Returns: 감정별 횟수 배열.
    static func emotionCounts(in items: [Retrospective]) -> [EmotionCount] {
        Emotion.allCases.map { EmotionCount(emotion: $0, count: count(of: $0, in: items)) }
    }

    /// 특정 감정으로 기록한 회고의 수를 셉니다.
    ///
    /// - Parameters:
    ///   - emotion: 셀 감정.
    ///   - items: 집계할 회고 목록.
    /// - Returns: 해당 감정의 기록 횟수.
    static func count(of emotion: Emotion, in items: [Retrospective]) -> Int {
        items.filter { $0.emotion == emotion }.count
    }
}
