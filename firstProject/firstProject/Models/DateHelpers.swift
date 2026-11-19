import Foundation

extension Locale {
    static let korean = Locale(identifier: "ko_KR")
}

extension Calendar {
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
