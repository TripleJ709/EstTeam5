import Foundation

/// 감정 하나와 그 기록 횟수입니다. 통계 막대 그래프의 한 칸에 해당합니다.
struct EmotionCount: Identifiable {
    /// 횟수를 센 감정입니다.
    let emotion: Emotion
    /// 해당 감정을 기록한 횟수입니다.
    let count: Int

    var id: Emotion { emotion }
}
