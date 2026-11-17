import Foundation

extension Emotion {
    /// 받침 유무에 따라 주격 조사 "이/가"를 돌려준다.
    var subjectParticle: String {
        guard let last = displayName.unicodeScalars.last,
              (0xAC00...0xD7A3).contains(last.value) else { return "이" }
        return (last.value - 0xAC00) % 28 == 0 ? "가" : "이"
    }
}
