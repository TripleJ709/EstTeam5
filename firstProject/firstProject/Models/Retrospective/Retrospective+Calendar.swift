import Foundation

/// 달력 표시를 위한 회고 조회 및 요약 기능입니다.
extension Retrospective {
    /// 지정한 날짜에 작성된 회고 중 가장 늦게 생성된 회고를 반환합니다.
    ///
    /// - Parameters:
    ///   - items: 검색할 회고 목록입니다.
    ///   - date: 대상 날짜입니다.
    ///   - calendar: 같은 날 판단에 사용할 달력입니다. 기본값은 `.current`입니다.
    /// - Returns: 해당 날짜의 회고가 없으면 `nil`입니다.
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
    /// 횟수가 같으면 `Emotion.allCases`에서 먼저 나오는 감정이 선택됩니다.
    ///
    /// - Parameter items: 대상 회고 목록입니다.
    /// - Returns: 기록이 하나도 없으면 `nil`입니다.
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

    /// 지정한 달의 회고를 요약한 문구를 반환합니다.
    ///
    /// 그 달에 기록이 없으면 첫 회고를 권하는 문구를, 있으면 가장 많은 감정과 기록 개수를 담은 문구를 반환합니다.
    ///
    /// - Parameters:
    ///   - items: 전체 회고 목록입니다.
    ///   - month: 대상 달에 속한 날짜입니다.
    ///   - calendar: 계산에 사용할 달력입니다. 기본값은 `.current`입니다.
    /// - Returns: 요약 문구입니다.
    static func monthSummary(of items: [Retrospective], month: Date, calendar: Calendar = .current) -> String {
        let monthItems = inPeriod(items, .month, of: month, calendar: calendar)
        guard let top = topEmotion(in: monthItems) else { return "첫 회고를 남기면 달력에 색이 채워져요" }
        return "이번 달은 \(top.displayName)\(top.subjectParticle) 가장 많았어요 · \(monthItems.count)개의 기록"
    }
}
