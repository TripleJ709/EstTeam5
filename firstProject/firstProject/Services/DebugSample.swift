#if DEBUG
import Foundation
import SwiftData

/// Figma 상태별 시안(01-A~F)을 재현하는 디버그 전용 샘플. 메모리 DB에만 넣는다.
///
/// 실행 인자: `-seedSample [-seedMode default|noToday|double|empty] [-selectDay N]`
/// - default: 시안의 2026년 11월 기록 13건(16일 기록 있음)
/// - noToday: 16일 기록만 빠진 12건 (01-B)
/// - double: 16일에 기록 2건 (01-D)
/// - empty: 기록 0건, 오늘부터 사용 시작 (01-F)
enum DebugSample {
    static let isSeeding = CommandLine.arguments.contains("-seedSample")

    static let today = date(2026, 11, 16)
    static var installDate: Date {
        Calendar.current.startOfDay(for: mode == "empty" ? today : date(2026, 11, 1))
    }
    static var selectedDate: Date {
        let day = UserDefaults.standard.integer(forKey: "selectDay")
        return day > 0 ? date(2026, 11, day) : today
    }

    private static var mode: String { UserDefaults.standard.string(forKey: "seedMode") ?? "default" }

    private static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? .now
    }

    static func seed(_ context: ModelContext) {
        guard mode != "empty" else { return }
        var samples: [(Int, Emotion)] = [
            (1, .stable), (2, .joy), (4, .sad), (5, .joy), (6, .fear), (7, .angry),
            (9, .achievement), (10, .stable), (11, .joy), (12, .sad), (13, .achievement),
            (15, .exhausted), (16, .joy),
        ]
        if mode == "noToday" { samples.removeAll { $0.0 == 16 } }

        for (day, emotion) in samples {
            let hour = (day == 16 && mode == "double") ? 21 : 12
            insert(context, date(2026, 11, day, hour, day == 16 ? 12 : 0), emotion,
                   "팀 프로젝트 첫 회의에서 각자 역할을 정했다. 처음이라 걱정했는데 생각보다 의견이 잘 맞아서 순조롭게 끝났다.")
        }
        if mode == "double" {
            insert(context, date(2026, 11, 16, 13, 5), .achievement, "발표 자료를 혼자 끝까지 정리해서 뿌듯했다.")
        }
    }

    private static func insert(_ context: ModelContext, _ date: Date, _ emotion: Emotion, _ content: String) {
        let item = Retrospective(date: date, content: content, emotion: emotion)
        item.createdAt = date
        context.insert(item)
    }
}
#endif
