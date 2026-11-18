import Foundation

extension Emotion {
    var subjectParticle: String {
        guard let last = displayName.unicodeScalars.last,
              (0xAC00...0xD7A3).contains(last.value) else { return "이" }
        return (last.value - 0xAC00) % 28 == 0 ? "가" : "이"
    }
}
