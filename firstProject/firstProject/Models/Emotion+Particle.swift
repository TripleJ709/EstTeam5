import Foundation

// 감정 이름 뒤에 붙는 조사(주격 조사 "이/가")를 감정별로 직접 지정하는 확장.
// 예: "기쁨" + "이", "분노" + "가"
extension Emotion {
    var subjectParticle: String {
        switch self {
        case .joy: return "이"          // 기쁨 (받침 ㅁ)
        case .achievement: return "가"  // 성취 (받침 없음)
        case .stable: return "이"       // 안정 (받침 ㅇ)
        case .angry: return "가"        // 분노 (받침 없음)
        case .fear: return "이"         // 두려움 (받침 ㅁ)
        case .sad: return "이"          // 슬픔 (받침 ㅁ)
        case .exhausted: return "이"    // 소진 (받침 ㄴ)
        }
    }
}
 
