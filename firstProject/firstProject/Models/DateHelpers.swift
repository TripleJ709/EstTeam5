import Foundation

/// `Locale` 확장입니다.
extension Locale {
    /// 한국어(`ko_KR`) 로케일입니다.
    static let korean = Locale(identifier: "ko_KR")
}

/// `Calendar` 확장입니다.
extension Calendar {
    /// 날짜 구간에 속한 날짜를 하루 단위로 나열합니다.
    ///
    /// 구간의 시작부터 하루씩 더하며, 끝 날짜 이전까지 포함합니다. 다음 날짜를 계산하지 못하면 거기서 멈춥니다.
    ///
    /// - Parameter interval: 나열할 날짜 구간입니다.
    /// - Returns: 구간에 속한 날짜 배열입니다.
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
