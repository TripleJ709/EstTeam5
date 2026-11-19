import Foundation

/// 회고를 작성하거나 수정하는 동안 임시로 보관하는 초안입니다.
struct RetrospectiveDraft {
    /// 본문의 최대 글자 수입니다. 500자입니다.
    static let maxLength = 500

    /// 회고 날짜입니다.
    var date: Date
    /// 선택한 감정입니다. 선택 전에는 `nil`입니다.
    var emotion: Emotion?
    /// 회고 본문입니다.
    var content: String

    /// 초안을 생성합니다.
    ///
    /// - Parameters:
    ///   - date: 회고 날짜입니다. 기본값은 현재 시각입니다.
    ///   - emotion: 선택한 감정입니다. 기본값은 `nil`입니다.
    ///   - content: 회고 본문입니다. 기본값은 빈 문자열입니다.
    init(date: Date = .now, emotion: Emotion? = nil, content: String = "") {
        self.date = date
        self.emotion = emotion
        self.content = content
    }

    /// 기존 회고의 날짜, 감정, 본문을 복사해 초안을 생성합니다.
    ///
    /// - Parameter retrospective: 복사할 기존 회고입니다.
    init(_ retrospective: Retrospective) {
        self.init(date: retrospective.date, emotion: retrospective.emotion, content: retrospective.content)
    }

    /// 앞뒤 공백과 줄바꿈을 제거한 본문입니다.
    var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 저장할 수 있는지 여부입니다. 감정이 선택되어 있고 공백을 제외한 본문이 비어 있지 않아야 합니다.
    var canSave: Bool {
        emotion != nil && !trimmedContent.isEmpty
    }

    /// 추천을 요청할 수 있는지 여부입니다. 공백을 제외한 본문이 비어 있지 않아야 합니다.
    var canRecommend: Bool {
        !trimmedContent.isEmpty
    }

    /// 본문이 `maxLength`를 넘으면 앞에서부터 `maxLength`자까지만 남깁니다.
    mutating func clampContent() {
        if content.count > Self.maxLength {
            content = String(content.prefix(Self.maxLength))
        }
    }

    /// 초안의 날짜에 다른 값의 시각을 합친 날짜를 반환합니다.
    ///
    /// 초안 `date`의 연·월·일과 `time`의 시·분·초를 사용합니다. 합친 날짜를 만들지 못하면 초안의 `date`를 반환합니다.
    ///
    /// - Parameters:
    ///   - time: 시각을 가져올 날짜 값입니다.
    ///   - calendar: 계산에 사용할 캘린더입니다. 기본값은 `.current`입니다.
    /// - Returns: 날짜와 시각을 합친 `Date`입니다.
    func combinedDate(timeFrom time: Date, calendar: Calendar = .current) -> Date {
        var parts = calendar.dateComponents([.year, .month, .day], from: date)
        let timeParts = calendar.dateComponents([.hour, .minute, .second], from: time)
        parts.hour = timeParts.hour
        parts.minute = timeParts.minute
        parts.second = timeParts.second
        return calendar.date(from: parts) ?? date
    }
}
