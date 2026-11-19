import Foundation

extension Emotion {
    /// 감정 이름 뒤에 붙이는 주격 조사입니다. 예: `성취가`, `기쁨이`
    ///
    /// 받침 유무에 맞게 감정마다 미리 정해 두었습니다.
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
