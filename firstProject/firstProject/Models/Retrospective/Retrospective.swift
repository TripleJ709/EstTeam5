import Foundation
import SwiftData

// 하루의 회고 한 건을 나타내는 데이터 모델.
// @Model을 붙이면 SwiftData가 이 클래스를 자동으로 DB에 저장/조회할 수 있게 해준다.
@Model
final class Retrospective {
    // 회고를 쓴 날짜
    var date: Date
    // 회고 본문
    var content: String
    // 감정을 문자열로 저장한 값 (DB에는 enum 대신 rawValue 문자열을 저장)
    var emotionRaw: String
    // 데이터가 실제로 생성된 시각
    var createdAt: Date

    // 새 회고를 만들 때 쓰는 생성자.
    // date를 생략하면 기본값 .now(지금 시각)가 들어간다.
    init(date: Date = .now, content: String, emotion: Emotion) {
        self.date = date
        self.content = content
        self.emotionRaw = emotion.rawValue
        self.createdAt = .now
    }

    // 저장은 문자열(emotionRaw)로 하고, 사용할 때는 Emotion 타입으로 쓰기 위한 계산 프로퍼티.
    var emotion: Emotion {
        // 읽을 때: 문자열을 Emotion으로 변환. 변환에 실패하면 .fallback(기본 감정)을 사용한다.
        get { Emotion(rawValue: emotionRaw) ?? .fallback }
        // 쓸 때: 새 Emotion 값(newValue)을 문자열로 바꿔서 저장한다.
        set { emotionRaw = newValue.rawValue }
    }
}
