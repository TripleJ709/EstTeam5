import Foundation

extension Retrospective {
    /// 같은 날 쓴 회고 중 가장 늦게 만든 한 건을 찾습니다.
    ///
    /// - Parameters:
    ///   - items: 찾을 대상 회고 목록.
    ///   - date: 기준 날짜. 시각은 무시하고 날짜만 비교합니다.
    ///   - calendar: 날짜 비교에 쓸 캘린더. 기본값은 현재 캘린더입니다.
    /// - Returns: 그날의 최신 회고. 그날 쓴 회고가 없으면 `nil`입니다.
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

    /// 가장 많이 기록한 감정을 찾습니다.
    ///
    /// 횟수가 같으면 `Emotion.allCases` 순서에서 앞선 감정을 고릅니다.
    ///
    /// - Parameter items: 집계할 회고 목록.
    /// - Returns: 가장 많이 기록한 감정. 기록이 없으면 `nil`입니다.
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

    /// 달력 아래에 보여 주는 한 달 요약 문장을 만듭니다.
    /// 예: `이번 달은 성취가 가장 많았어요 · 5개의 기록`
    ///
    /// - Parameters:
    ///   - items: 전체 회고 목록.
    ///   - month: 요약할 달에 속한 날짜.
    ///   - calendar: 날짜 비교에 쓸 캘린더. 기본값은 현재 캘린더입니다.
    /// - Returns: 요약 문장. 그 달에 기록이 없으면 첫 회고를 권하는 안내 문구입니다.
    static func monthSummary(of items: [Retrospective], month: Date, calendar: Calendar = .current) -> String {
        let monthItems = inPeriod(items, .month, of: month, calendar: calendar)
        guard let top = topEmotion(in: monthItems) else { return "첫 회고를 남기면 달력에 색이 채워져요" }
        return "이번 달은 \(top.displayName)\(top.subjectParticle) 가장 많았어요 · \(monthItems.count)개의 기록"
    }
}
