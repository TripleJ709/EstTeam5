import Foundation

/// `Emotion`의 한국어 조사 처리를 제공합니다.
extension Emotion {
    /// 감정 이름 뒤에 붙는 주격 조사입니다. 기쁨·안정·두려움·슬픔·소진은 '이', 성취·분노는 '가'입니다.
    var subjectParticle: String {
        switch self {
        case .joy: return "이"
        case .achievement: return "가"
        case .stable: return "이"
        case .angry: return "가"
        case .fear: return "이"
        case .sad: return "이"
        case .exhausted: return "이"
        }
    }
}
