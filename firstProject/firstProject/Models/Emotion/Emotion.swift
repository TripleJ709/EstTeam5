import SwiftUI

/// 회고에 기록하는 감정의 종류입니다.
enum Emotion: String, CaseIterable, Identifiable, Decodable {
    /// 기쁨입니다.
    case joy
    /// 성취입니다.
    case achievement
    /// 안정입니다.
    case stable
    /// 분노입니다.
    case angry
    /// 두려움입니다.
    case fear
    /// 슬픔입니다.
    case sad
    /// 소진입니다.
    case exhausted

    /// 식별자로 사용하는 원시 값입니다.
    var id: String { rawValue }

    /// 알 수 없는 값일 때 대신 쓰는 기본 감정입니다. `.stable`입니다.
    static let fallback: Emotion = .stable

    /// 화면에 표시하는 한국어 감정 이름입니다.
    var displayName: String {
        switch self {
        case .joy: return "기쁨"
        case .achievement: return "성취"
        case .stable: return "안정"
        case .angry: return "분노"
        case .fear: return "두려움"
        case .sad: return "슬픔"
        case .exhausted: return "소진"
        }
    }

    /// 오라 그라디언트의 시작 색입니다. 에셋 카탈로그의 `<원시 값>AuraStart` 색을 사용합니다.
    var auraStart: Color { Color("\(rawValue)AuraStart") }
    /// 오라 그라디언트의 끝 색입니다. 에셋 카탈로그의 `<원시 값>AuraEnd` 색을 사용합니다.
    var auraEnd: Color { Color("\(rawValue)AuraEnd") }
}
