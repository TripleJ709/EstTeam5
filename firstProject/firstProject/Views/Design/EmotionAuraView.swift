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
