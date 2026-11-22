import Foundation

/// 로케일 보조 기능입니다.
extension Locale {
    /// 한국어(`ko_KR`) 로케일입니다.
    static let korean = Locale(identifier: "ko_KR")
}

/// 달력 보조 기능입니다.
extension Calendar {
    /// 구간에 포함된 날짜를 하루 간격으로 나열합니다.
    ///
    /// 구간의 시작부터 하루씩 더하며 끝 전까지의 날짜를 모읍니다.
    ///
    /// - Parameter interval: 대상 날짜 구간입니다.
    /// - Returns: 구간 안의 날짜 배열입니다.
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
