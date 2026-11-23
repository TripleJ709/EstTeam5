import Foundation
import SwiftData

/// 사용자가 남긴 회고 한 건을 나타내는 SwiftData 모델입니다.
@Model
/// 회고 모델 클래스입니다.
final class Retrospective {
    /// 회고 날짜입니다.
    var date: Date
    /// 회고 본문입니다.
    var content: String
    /// 감정의 원시값(`Emotion.rawValue`)입니다.
    var emotionRaw: String
    /// 회고가 생성된 시각입니다.
    var createdAt: Date

    /// 회고를 생성합니다. `createdAt`은 생성 시점의 현재 시각으로 설정됩니다.
    ///
    /// - Parameters:
    ///   - date: 회고 날짜입니다. 기본값은 현재 시각입니다.
    ///   - content: 회고 본문입니다.
    ///   - emotion: 회고의 감정입니다.
    init(date: Date = .now, content: String, emotion: Emotion) {
        self.date = date
        self.content = content
        self.emotionRaw = emotion.rawValue
        self.createdAt = .now
    }

    /// 회고의 감정입니다.
    ///
    /// 저장된 원시값이 유효하지 않으면 `Emotion.fallback`을 반환합니다.
    var emotion: Emotion {
        get { Emotion(rawValue: emotionRaw) ?? .fallback }
        set { emotionRaw = newValue.rawValue }
    }
}
