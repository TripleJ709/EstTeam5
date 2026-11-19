import Foundation

/// 작성하거나 편집하는 중인 회고 내용을 담는 임시 값입니다.
///
/// 저장 버튼을 누르기 전까지는 SwiftData 모델(`Retrospective`)과 분리해 둡니다.
struct RetrospectiveDraft {
    /// 회고 본문의 최대 글자 수입니다.
    static let maxLength = 500

    /// 회고를 남길 날짜입니다.
    var date: Date
    /// 선택한 감정입니다. 아직 고르지 않았으면 `nil`입니다.
    var emotion: Emotion?
    /// 회고 본문입니다.
    var content: String

    /// 빈 초안, 또는 값이 채워진 초안을 만듭니다.
    ///
    /// - Parameters:
    ///   - date: 회고를 남길 날짜. 기본값은 지금입니다.
    ///   - emotion: 선택한 감정. 기본값은 선택 없음입니다.
    ///   - content: 회고 본문. 기본값은 빈 문자열입니다.
    init(date: Date = .now, emotion: Emotion? = nil, content: String = "") {
        self.date = date
        self.emotion = emotion
        self.content = content
    }

    /// 저장된 회고에서 편집용 초안을 만듭니다.
    ///
    /// - Parameter retrospective: 편집할 회고.
    init(_ retrospective: Retrospective) {
        self.init(date: retrospective.date, emotion: retrospective.emotion, content: retrospective.content)
    }

    /// 앞뒤 공백과 줄바꿈을 없앤 본문입니다.
    var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 저장할 수 있는지 여부입니다. 감정을 골랐고 본문이 비어 있지 않아야 합니다.
    var canSave: Bool {
        emotion != nil && !trimmedContent.isEmpty
    }

    /// AI 감정 추천을 받을 수 있는지 여부입니다. 본문이 비어 있지 않아야 합니다.
    var canRecommend: Bool {
        !trimmedContent.isEmpty
    }

    /// 본문이 최대 글자 수(`maxLength`)를 넘으면 앞에서부터 그 길이까지만 남깁니다.
    mutating func clampContent() {
        if content.count > Self.maxLength {
            content = String(content.prefix(Self.maxLength))
        }
    }

    /// 초안의 날짜에 다른 시각을 합친 날짜를 만듭니다.
    ///
    /// 날짜 선택기는 날짜만 고르므로, 저장할 때 지금 시각의 시·분·초를 붙입니다.
    ///
    /// - Parameters:
    ///   - time: 시·분·초를 가져올 시각.
    ///   - calendar: 날짜 계산에 쓸 캘린더. 기본값은 현재 캘린더입니다.
    /// - Returns: 날짜와 시각을 합친 값. 합칠 수 없으면 초안의 원래 날짜입니다.
    func combinedDate(timeFrom time: Date, calendar: Calendar = .current) -> Date {
        var parts = calendar.dateComponents([.year, .month, .day], from: date)
        let timeParts = calendar.dateComponents([.hour, .minute, .second], from: time)
        parts.hour = timeParts.hour
        parts.minute = timeParts.minute
        parts.second = timeParts.second
        return calendar.date(from: parts) ?? date
    }
}
