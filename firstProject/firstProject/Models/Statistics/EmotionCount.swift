import Foundation

/// 감정 하나와 그 감정이 기록된 횟수를 묶은 값입니다.
struct EmotionCount: Identifiable {
    /// 집계 대상 감정입니다.
    let emotion: Emotion
    /// 해당 감정의 기록 횟수입니다.
    let count: Int

    /// 식별자로 사용하는 감정 값입니다.
    var id: Emotion { emotion }
}
