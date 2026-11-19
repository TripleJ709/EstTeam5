import Foundation

struct EmotionCount: Identifiable {
    let emotion: Emotion
    let count: Int

    var id: Emotion { emotion }
}
