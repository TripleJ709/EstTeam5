import Foundation

/// 통계를 보는 기간 단위입니다.
enum StatisticsPeriod: String, CaseIterable, Identifiable {
    /// 주간 단위입니다.
    case week = "주간"
    /// 월간 단위입니다.
    case month = "월간"

    /// 식별자로 원시값을 사용합니다.
    var id: String { rawValue }

    /// 기간 단위에 대응하는 달력 구성 요소입니다. 주간은 `.weekOfYear`, 월간은 `.month`입니다.
    var calendarComponent: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        }
    }

    /// 기록 개수 표시에 쓰는 문구입니다.
    var recordCountLabel: String {
        switch self {
        case .week: "이번 주 기록"
        case .month: "이번 달 기록"
        }
    }

    /// 기록이 없을 때 보여줄 제목 문구입니다.
    var emptyTitle: String {
        switch self {
        case .week: "이 주에는 기록이 없어요"
        case .month: "이 달에는 기록이 없어요"
        }
    }

    /// 피드백 영역의 제목 문구입니다.
    var feedbackTitle: String {
        switch self {
        case .week: "이번 주의 한마디"
        case .month: "이번 달의 한마디"
        }
    }

    /// 감정에 대한 기간별 피드백 문구를 반환합니다.
    ///
    /// - Parameter emotion: 피드백을 가져올 감정입니다.
    /// - Returns: 주간이면 `weeklyFeedback`, 월간이면 `monthlyFeedback` 문구입니다.
    func feedback(for emotion: Emotion) -> String {
        switch self {
        case .week: emotion.weeklyFeedback
        case .month: emotion.monthlyFeedback
        }
    }

    /// 기준 날짜가 속한 기간의 모든 날짜를 반환합니다.
    ///
    /// 기간을 구할 수 없으면 빈 배열을 반환합니다.
    ///
    /// - Parameters:
    ///   - anchor: 기준 날짜입니다.
    ///   - calendar: 계산에 사용할 달력입니다. 기본값은 `.current`입니다.
    /// - Returns: 기간에 포함된 날짜 배열입니다.
    func days(of anchor: Date, calendar: Calendar = .current) -> [Date] {
        guard let interval = calendar.dateInterval(of: calendarComponent, for: anchor) else { return [] }
        return calendar.days(in: interval)
    }

    /// 기준 날짜가 속한 기간의 표시용 제목을 반환합니다.
    ///
    /// 월간은 한국어 로케일의 연도와 월 형식입니다. 주간은 "시작일 – 종료일" 형식이며, 같은 달이면 종료일에는 일만 표시합니다.
    /// 주간 기간을 구할 수 없으면 빈 문자열을 반환합니다.
    ///
    /// - Parameters:
    ///   - anchor: 기준 날짜입니다.
    ///   - calendar: 계산에 사용할 달력입니다. 기본값은 `.current`입니다.
    /// - Returns: 기간 제목 문자열입니다.
    func title(of anchor: Date, calendar: Calendar = .current) -> String {
        switch self {
        case .month:
            return anchor.formatted(.dateTime.year().month(.wide).locale(.korean))
        case .week:
            let periodDays = days(of: anchor, calendar: calendar)
            guard let first = periodDays.first, let last = periodDays.last else { return "" }
            let startStyle = Date.FormatStyle.dateTime.month().day().locale(.korean)
            let endStyle = calendar.isDate(first, equalTo: last, toGranularity: .month)
                ? Date.FormatStyle.dateTime.day().locale(.korean)
                : startStyle
            return "\(first.formatted(startStyle)) – \(last.formatted(endStyle))"
        }
    }

    /// 기준 날짜를 기간 단위로 지정한 만큼 이동한 날짜를 반환합니다.
    ///
    /// 계산에 실패하면 기준 날짜를 그대로 반환합니다.
    ///
    /// - Parameters:
    ///   - anchor: 기준 날짜입니다.
    ///   - value: 이동할 기간 수입니다. 음수이면 과거로 이동합니다.
    ///   - calendar: 계산에 사용할 달력입니다. 기본값은 `.current`입니다.
    /// - Returns: 이동한 날짜입니다.
    func moved(_ anchor: Date, by value: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: calendarComponent, value: value, to: anchor) ?? anchor
    }
}
