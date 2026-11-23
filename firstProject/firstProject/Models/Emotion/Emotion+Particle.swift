import Foundation

/// 감정 이름에 붙는 조사 기능입니다.
extension Emotion {
    /// 감정 이름 뒤에 붙는 주격 조사입니다. 성취와 분노는 "가", 나머지는 "이"입니다.
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
