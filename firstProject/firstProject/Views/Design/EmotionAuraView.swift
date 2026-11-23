import SwiftUI

/// 감정에 해당하는 오로라 이미지를 보여주는 뷰입니다.
struct EmotionAuraView: View {
    /// 표시할 감정입니다.
    let emotion: Emotion
    /// 뷰의 한 변 길이입니다. 기본값은 28입니다.
    var size: CGFloat = 28
    /// `true`이면 표정이 있는 이미지를, `false`이면 표정 없는 이미지를 사용합니다. 기본값은 `true`입니다.
    var showsFace: Bool = true

    /// 이미지를 `size`보다 크게 그려 글로우 여백을 만드는 배율입니다.
    private let glowScale: CGFloat = 1.3

    /// `showsFace`에 따라 `<감정>Aura` 또는 `<감정>AuraExpressionless` 이미지 이름을 반환합니다.
    private var imageName: String {
        if showsFace {
            return "\(emotion.rawValue)Aura"
        } else {
            return "\(emotion.rawValue)AuraExpressionless"
        }
    }

    /// 화면 구성: 이미지를 `size`의 1.3배로 그린 뒤 `size` 크기 프레임에 배치하며, 접근성에서는 숨깁니다.
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size * glowScale, height: size * glowScale)
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

/// 감정의 시작·끝 색으로 만든 방사형 그라데이션 배경 효과 뷰입니다.
struct EmotionWash: View {
    /// 색상에 사용할 감정입니다.
    let emotion: Emotion
    /// 그라데이션의 불투명도입니다. 기본값은 0.75입니다.
    var opacity: Double = 0.75
    /// 블러 반경입니다. 기본값은 20입니다.
    var blur: CGFloat = 20

    /// 화면 구성: 420×420 원에 방사형 그라데이션을 채우고 블러를 적용하며, 터치와 접근성에서는 제외합니다.
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
