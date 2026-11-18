import Foundation

// 감정 이름 뒤에 붙는 조사(주격 조사 "이/가")를 계산하는 확장.
// 예: "기쁨" + "이", "슬퍼" + "가"
extension Emotion {
    // 한글 글자 계산에 쓰는 상수 모음. 이 파일 안에서만 사용한다(private).
    // case가 없는 enum은 상수를 이름으로 묶어두는 용도로 쓴다.
    private enum Hangul {
        // 완성형 한글(가 ~ 힣)의 유니코드 번호 범위. 0xAC00 = "가", 0xD7A3 = "힣"
        static let syllables: ClosedRange<UInt32> = 0xAC00...0xD7A3
        // 받침 종류의 개수. 받침 없음 1가지 + 받침 27가지 = 28
        static let finalConsonantCount: UInt32 = 28
    }

    // 감정 이름(displayName)의 마지막 글자에 받침이 있으면 "이", 없으면 "가"를 반환한다.
    var subjectParticle: String {
        // 마지막 글자를 꺼내고, 완성형 한글인지 확인한다.
        // 글자가 없거나 한글이 아니면 기본값 "이"를 반환하고 끝낸다.
        guard let last = displayName.unicodeScalars.last,
              Hangul.syllables.contains(last.value) else { return "이" }

        // "가"로부터의 거리를 28로 나눈 나머지가 받침 번호다. 0이면 받침이 없다.
        let hasFinalConsonant = (last.value - Hangul.syllables.lowerBound) % Hangul.finalConsonantCount != 0
        return hasFinalConsonant ? "이" : "가"
    }
}
