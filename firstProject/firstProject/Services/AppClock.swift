import Foundation

/// 앱 전체에서 "오늘"과 사용 시작일을 한곳에서 정한다.
enum AppClock {
    /// 오늘 시각. 디버그 샘플 실행 중에는 시안 기준일(2026-11-16)로 고정된다.
    static var now: Date {
        #if DEBUG
        if DebugSample.isSeeding { return DebugSample.today }
        #endif
        return .now
    }

    /// 앱을 처음 쓴 날의 시작 시각. 이 날 이전에는 "기록 안 한 날" 표시를 하지 않는다.
    static var installDate: Date {
        #if DEBUG
        if DebugSample.isSeeding { return DebugSample.installDate }
        #endif
        let key = "installDate"
        if let saved = UserDefaults.standard.object(forKey: key) as? Date { return saved }
        let start = Calendar.current.startOfDay(for: .now)
        UserDefaults.standard.set(start, forKey: key)
        return start
    }
}
