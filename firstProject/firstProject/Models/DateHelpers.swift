import Foundation

extension Locale {
    /// 앱 전체에서 날짜와 문구를 표시할 때 쓰는 한국어 로케일입니다.
    static let korean = Locale(identifier: "ko_KR")
}

extension Calendar {
    /// 기간 안에 들어 있는 날짜를 하루 간격으로 나열합니다.
    ///
    /// 기간의 시작 시각부터 하루씩 더해 가며, 끝 시각 직전까지의 날짜를 담습니다.
    ///
    /// - Parameter interval: 날짜를 나열할 기간. 예를 들어 한 주나 한 달입니다.
    /// - Returns: 기간에 포함된 날짜 배열. 기간이 비어 있으면 빈 배열입니다.
    func days(in interval: DateInterval) -> [Date] {
        var result: [Date] = []
        var cursor = interval.start
        while cursor < interval.end {
            result.append(cursor)
            guard let next = date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }
}
