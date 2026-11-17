import SwiftUI

/// 감정 아우라 구슬: 2색 방사형 그라데이션 몸체 + 아래로 살짝 번지는 같은 색 글로우
struct EmotionAuraView: View {
    let emotion: Emotion
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            orb
                .opacity(0.5)
                .blur(radius: size * 3 / 40)
            orb
                .offset(y: -size * 3 / 40)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var orb: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [emotion.auraStart, emotion.auraEnd],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach(Emotion.allCases) { EmotionAuraView(emotion: $0, size: 40) }
    }
    .padding()
    .background(FeeloColor.bgApp)
}

/// 선택한 감정 색이 화면 위쪽으로 번지는 배경
struct EmotionWash: View {
    let emotion: Emotion
    var opacity: Double = 0.75
    var blur: CGFloat = 20

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [emotion.auraStart, emotion.auraEnd.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: 210
                )
            )
            .frame(width: 420, height: 420)
            .opacity(opacity)
            .blur(radius: blur)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
