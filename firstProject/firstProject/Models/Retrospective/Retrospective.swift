import Foundation
import SwiftData

@Model
final class Retrospective {
    var date: Date
    var content: String
    var emotionRaw: String
    var createdAt: Date

    init(date: Date = .now, content: String, emotion: Emotion) {
        self.date = date
        self.content = content
        self.emotionRaw = emotion.rawValue
        self.createdAt = .now
    }

    var emotion: Emotion {
        get { Emotion(rawValue: emotionRaw) ?? .fallback }
        set { emotionRaw = newValue.rawValue }
    }
}
