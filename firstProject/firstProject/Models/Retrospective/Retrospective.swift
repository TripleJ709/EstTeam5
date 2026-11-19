import Foundation
import SwiftData

/// 하루의 회고 한 건을 나타내는 SwiftData 모델입니다.
@Model
final class Retrospective {
    /// 회고 날짜입니다.
    var date: Date
    /// 회고 본문입니다.
    var content: String
    /// 감정의 원시 값 문자열입니다. 접근은 `emotion` 프로퍼티를 사용합니다.
    var emotionRaw: String
    /// 회고를 생성한 시각입니다.
    var createdAt: Date

    /// 회고를 생성합니다. `createdAt`은 생성 시점의 현재 시각으로 설정됩니다.
    ///
    /// - Parameters:
    ///   - date: 회고 날짜입니다. 기본값은 현재 시각입니다.
    ///   - content: 회고 본문입니다.
    ///   - emotion: 선택한 감정입니다.
    init(date: Date = .now, content: String, emotion: Emotion) {
        self.date = date
        self.content = content
        self.emotionRaw = emotion.rawValue
        self.createdAt = .now
    }

    /// 회고의 감정입니다.
    ///
    /// `emotionRaw`를 `Emotion`으로 변환합니다. 변환할 수 없으면 `Emotion.fallback`을 반환합니다.
    var emotion: Emotion {
        get { Emotion(rawValue: emotionRaw) ?? .fallback }
        set { emotionRaw = newValue.rawValue }
    }
}
