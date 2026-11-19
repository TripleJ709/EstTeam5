import Foundation

/// `Retrospective`의 날짜 기반 조회와 요약 기능을 제공합니다.
extension Retrospective {
    /// 지정한 날짜와 같은 날의 회고 중 가장 늦게 작성된 회고를 반환합니다.
    ///
    /// 같은 날의 회고가 없으면 `nil`을 반환합니다. 가장 늦은 회고는 `createdAt`으로 판단합니다.
    ///
    /// - Parameters:
    ///   - items: 검색할 회고 목록입니다.
    ///   - date: 기준 날짜입니다.
    ///   - calendar: 같은 날 판단에 사용할 캘린더입니다. 기본값은 `.current`입니다.
    /// - Returns: 가장 늦게 작성된 회고이거나 `nil`입니다.
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

    /// 회고 목록에서 가장 많이 기록된 감정을 반환합니다.
    ///
    /// `Emotion.allCases` 순서로 확인하며, 횟수가 같으면 먼저 나온 감정을 유지합니다. 기록이 없으면 `nil`을 반환합니다.
    ///
    /// - Parameter items: 집계할 회고 목록입니다.
    /// - Returns: 가장 많이 기록된 감정이거나 `nil`입니다.
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

    /// 지정한 달의 회고를 한 문장으로 요약합니다.
    ///
    /// 그 달에 회고가 없으면 첫 회고를 권하는 문구를 반환합니다. 있으면 가장 많았던 감정과 기록 개수를 담은 문구를 반환합니다.
    ///
    /// - Parameters:
    ///   - items: 전체 회고 목록입니다.
    ///   - month: 요약할 달에 속한 날짜입니다.
    ///   - calendar: 달 계산에 사용할 캘린더입니다. 기본값은 `.current`입니다.
    /// - Returns: 월 요약 문구입니다.
    static func monthSummary(of items: [Retrospective], month: Date, calendar: Calendar = .current) -> String {
        let monthItems = inPeriod(items, .month, of: month, calendar: calendar)
        guard let top = topEmotion(in: monthItems) else { return "첫 회고를 남기면 달력에 색이 채워져요" }
        return "이번 달은 \(top.displayName)\(top.subjectParticle) 가장 많았어요 · \(monthItems.count)개의 기록"
    }
}
