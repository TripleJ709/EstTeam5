import SwiftUI

/// 회고에 기록하는 7가지 감정입니다.
///
/// `rawValue`는 저장과 AI 응답에 쓰는 영문 키이고, 화면에 보이는 이름은 `displayName`입니다.
/// 감정마다 아우라 색(`auraStart`, `auraEnd`)이 정해져 있습니다.
enum Emotion: String, CaseIterable, Identifiable, Decodable {
    /// 기쁨. 즐거움, 행복, 설렘 같은 감정입니다.
    case joy
    /// 성취. 뿌듯함, 보람, 만족 같은 감정입니다.
    case achievement
    /// 안정. 평안, 평온, 안도 같은 감정입니다.
    case stable
    /// 분노. 화남, 짜증, 억울함 같은 감정입니다.
    case angry
    /// 두려움. 불안, 걱정, 초조 같은 감정입니다.
    case fear
    /// 슬픔. 우울, 서운함, 외로움 같은 감정입니다.
    case sad
    /// 소진. 피곤, 무기력, 번아웃 같은 감정입니다.
    case exhausted

    var id: String { rawValue }

    /// 저장된 값을 어떤 감정으로도 바꿀 수 없을 때 대신 쓰는 기본 감정(안정)입니다.
    static let fallback: Emotion = .stable

    /// 화면에 보여 주는 한국어 감정 이름입니다. 예: `기쁨`
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

    /// 아우라 그라데이션의 시작 색입니다. 에셋 카탈로그의 `<감정>AuraStart` 색을 사용합니다.
    var auraStart: Color { Color("\(rawValue)AuraStart") }
    /// 아우라 그라데이션의 끝 색입니다. 에셋 카탈로그의 `<감정>AuraEnd` 색을 사용합니다.
    var auraEnd: Color { Color("\(rawValue)AuraEnd") }
}
