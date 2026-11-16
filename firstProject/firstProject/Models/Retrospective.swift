import Foundation
import SwiftData

@Model
final class Retrospective {
    var id: UUID
    var date: Date
    var content: String
    var emotionRaw: String
    var createdAt: Date
    var updatedAt: Date
    var category: Category?

    init(date: Date = .now, content: String, emotion: Emotion, category: Category? = nil) {
        self.id = UUID()
        self.date = date
        self.content = content
        self.emotionRaw = emotion.rawValue
        self.createdAt = .now
        self.updatedAt = .now
        self.category = category
    }

    var emotion: Emotion {
        get { Emotion(rawValue: emotionRaw) ?? .fallback }
        set { emotionRaw = newValue.rawValue }
    }
}
