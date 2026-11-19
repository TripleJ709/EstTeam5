import Foundation
import SwiftData

/// 하루의 회고 한 건입니다. SwiftData로 기기에 저장됩니다.
///
/// 같은 날에 여러 건을 쓸 수 있으며, 달력에는 그날 가장 늦게 만든 회고의 감정이 표시됩니다.
@Model
final class Retrospective {
    /// 회고를 남긴 날짜와 시각입니다.
    var date: Date
    /// 회고 본문입니다. 작성 화면에서 500자까지 입력할 수 있습니다.
    var content: String
    /// 저장용 감정 값(`Emotion.rawValue`)입니다. 코드에서는 `emotion`을 사용합니다.
    var emotionRaw: String
    /// 회고를 처음 만든 시각입니다. 같은 날 여러 건 중 최신 건을 고를 때 씁니다.
    var createdAt: Date

    /// 새 회고를 만듭니다.
    ///
    /// - Parameters:
    ///   - date: 회고를 남길 날짜. 기본값은 지금입니다.
    ///   - content: 회고 본문.
    ///   - emotion: 선택한 감정.
    init(date: Date = .now, content: String, emotion: Emotion) {
        self.date = date
        self.content = content
        self.emotionRaw = emotion.rawValue
        self.createdAt = .now
    }

    /// 회고의 감정입니다. 저장된 값을 읽을 수 없으면 `Emotion.fallback`을 돌려줍니다.
    var emotion: Emotion {
        get { Emotion(rawValue: emotionRaw) ?? .fallback }
        set { emotionRaw = newValue.rawValue }
    }
}
