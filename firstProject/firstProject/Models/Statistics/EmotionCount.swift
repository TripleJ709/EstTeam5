import Foundation

/// 감정 하나와 그 기록 횟수를 담는 값입니다.
struct EmotionCount: Identifiable {
    /// 감정입니다.
    let emotion: Emotion
    /// 해당 감정의 기록 횟수입니다.
    let count: Int

    /// 식별자로 감정 자체를 사용합니다.
    var id: Emotion { emotion }
}
