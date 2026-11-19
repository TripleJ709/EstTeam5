import SwiftUI

/// 감정을 색 구슬(아우라) 이미지로 보여 주는 뷰입니다.
struct EmotionAuraView: View {
    /// 보여 줄 감정입니다.
    let emotion: Emotion
    /// 구슬의 가로·세로 크기입니다.
    var size: CGFloat = 28

    var body: some View {
        Image("\(emotion.rawValue)Aura")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach(Emotion.allCases) { EmotionAuraView(emotion: $0, size: 40) }
    }
    .padding()
    .background(Color.bgApp)
}

/// 감정 색이 번져 보이는 배경 효과입니다. 상세·작성 화면의 윗부분 배경에 씁니다.
struct EmotionWash: View {
    let emotion: Emotion
    /// 배경의 불투명도입니다.
    var opacity: Double = 0.75
    /// 번짐 정도입니다.
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
