import Foundation

/// 통계를 보는 기간 단위입니다.
enum StatisticsPeriod: String, CaseIterable, Identifiable {
    /// 주간 단위입니다.
    case week = "주간"
    /// 월간 단위입니다.
    case month = "월간"

    /// 식별자로 사용하는 원시 값입니다.
    var id: String { rawValue }

    /// 기간 계산에 사용하는 캘린더 구성 요소입니다. 주간은 `.weekOfYear`, 월간은 `.month`입니다.
    var calendarComponent: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        }
    }

    /// 기록 횟수 표시에 쓰는 문구입니다. 주간은 '이번 주 기록', 월간은 '이번 달 기록'입니다.
    var recordCountLabel: String {
        switch self {
        case .week: "이번 주 기록"
        case .month: "이번 달 기록"
        }
    }

    /// 기간에 기록이 없을 때 보여주는 제목 문구입니다.
    var emptyTitle: String {
        switch self {
        case .week: "이 주에는 기록이 없어요"
        case .month: "이 달에는 기록이 없어요"
        }
    }

    /// 피드백 영역에 쓰는 제목 문구입니다.
    var feedbackTitle: String {
        switch self {
        case .week: "이번 주의 한마디"
        case .month: "이번 달의 한마디"
        }
    }

    /// 기간 단위에 맞는 감정 피드백 문구를 반환합니다.
    ///
    /// 주간은 `weeklyFeedback`, 월간은 `monthlyFeedback`을 사용합니다.
    ///
    /// - Parameter emotion: 피드백을 받을 감정입니다.
    /// - Returns: 해당 기간 단위의 피드백 문구입니다.
    func feedback(for emotion: Emotion) -> String {
        switch self {
        case .week: emotion.weeklyFeedback
        case .month: emotion.monthlyFeedback
        }
    }

    /// 기준 날짜가 속한 기간의 모든 날짜를 반환합니다.
    ///
    /// 기간 구간을 구하지 못하면 빈 배열을 반환합니다.
    ///
    /// - Parameters:
    ///   - anchor: 기간을 결정하는 기준 날짜입니다.
    ///   - calendar: 계산에 사용할 캘린더입니다. 기본값은 `.current`입니다.
    /// - Returns: 기간에 속한 날짜 배열입니다.
    func days(of anchor: Date, calendar: Calendar = .current) -> [Date] {
        guard let interval = calendar.dateInterval(of: calendarComponent, for: anchor) else { return [] }
        return calendar.days(in: interval)
    }

    /// 기준 날짜가 속한 기간을 표시용 문자열로 만듭니다.
    ///
    /// 월간은 한국어 로케일의 연도와 월 형식입니다. 주간은 첫 날과 마지막 날을 ' – '로 이어 붙이며, 두 날짜가 같은 달이면 마지막 날은 일(day)만 표시합니다. 주간의 날짜를 구하지 못하면 빈 문자열을 반환합니다.
    ///
    /// - Parameters:
    ///   - anchor: 기간을 결정하는 기준 날짜입니다.
    ///   - calendar: 계산에 사용할 캘린더입니다. 기본값은 `.current`입니다.
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

    /// 기준 날짜를 기간 단위로 이동한 날짜를 반환합니다.
    ///
    /// 이동한 날짜를 계산하지 못하면 원래 기준 날짜를 반환합니다.
    ///
    /// - Parameters:
    ///   - anchor: 이동할 기준 날짜입니다.
    ///   - value: 이동할 기간 수입니다. 음수이면 과거로 이동합니다.
    ///   - calendar: 계산에 사용할 캘린더입니다. 기본값은 `.current`입니다.
    /// - Returns: 이동한 날짜입니다.
    func moved(_ anchor: Date, by value: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: calendarComponent, value: value, to: anchor) ?? anchor
    }
}
