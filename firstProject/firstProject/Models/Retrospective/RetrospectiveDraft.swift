import Foundation

/// 저장하기 전 작성 중인 회고 초안입니다.
struct RetrospectiveDraft: Equatable {
    /// 회고 본문의 최대 글자 수입니다.
    static let maxLength = 500

    /// 회고 날짜입니다.
    var date: Date
    /// 선택한 감정입니다. 선택하지 않았으면 `nil`입니다.
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

    /// 기존 회고의 날짜, 감정, 본문으로 초안을 생성합니다.
    ///
    /// - Parameter retrospective: 초안의 바탕이 될 회고입니다.
    init(_ retrospective: Retrospective) {
        self.init(date: retrospective.date, emotion: retrospective.emotion, content: retrospective.content)
    }

    /// 앞뒤 공백과 줄바꿈을 제거한 본문입니다.
    var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 저장 가능 여부입니다. 감정이 선택되어 있고 공백을 제외한 본문이 비어 있지 않아야 합니다.
    var canSave: Bool {
        emotion != nil && !trimmedContent.isEmpty
    }

    /// 추천 요청 가능 여부입니다. 공백을 제외한 본문이 비어 있지 않아야 합니다.
    var canRecommend: Bool {
        !trimmedContent.isEmpty
    }

    /// 본문이 `maxLength`를 넘으면 앞에서부터 `maxLength`글자만 남기고 자릅니다.
    mutating func clampContent() {
        if content.count > Self.maxLength {
            content = String(content.prefix(Self.maxLength))
        }
    }

    /// 초안의 날짜에 다른 값의 시각을 합친 날짜를 반환합니다.
    ///
    /// 연, 월, 일은 초안의 날짜에서, 시, 분, 초는 `time`에서 가져옵니다. 합칠 수 없으면 초안의 날짜를 반환합니다.
    ///
    /// - Parameters:
    ///   - time: 시각을 가져올 날짜입니다.
    ///   - calendar: 계산에 사용할 달력입니다. 기본값은 `.current`입니다.
    /// - Returns: 합쳐진 날짜입니다.
    func combinedDate(timeFrom time: Date, calendar: Calendar = .current) -> Date {
        var parts = calendar.dateComponents([.year, .month, .day], from: date)
        let timeParts = calendar.dateComponents([.hour, .minute, .second], from: time)
        parts.hour = timeParts.hour
        parts.minute = timeParts.minute
        parts.second = timeParts.second
        return calendar.date(from: parts) ?? date
    }
}
