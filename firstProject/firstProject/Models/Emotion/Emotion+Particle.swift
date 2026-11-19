import Foundation

extension Emotion {
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
