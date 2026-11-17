import Foundation

struct RetrospectiveDraft {
    static let maxLength = 500

    var date: Date
    var emotion: Emotion?
    var content: String

    init(date: Date = .now, emotion: Emotion? = nil, content: String = "") {
        self.date = date
        self.emotion = emotion
        self.content = content
    }

    init(_ retrospective: Retrospective) {
        self.init(date: retrospective.date, emotion: retrospective.emotion, content: retrospective.content)
    }

    var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        emotion != nil && !trimmedContent.isEmpty
    }

    mutating func clampContent() {
        if content.count > Self.maxLength {
            content = String(content.prefix(Self.maxLength))
        }
    }

    func combinedDate(timeFrom time: Date, calendar: Calendar = .current) -> Date {
        var parts = calendar.dateComponents([.year, .month, .day], from: date)
        let timeParts = calendar.dateComponents([.hour, .minute, .second], from: time)
        parts.hour = timeParts.hour
        parts.minute = timeParts.minute
        parts.second = timeParts.second
        return calendar.date(from: parts) ?? date
    }
}
