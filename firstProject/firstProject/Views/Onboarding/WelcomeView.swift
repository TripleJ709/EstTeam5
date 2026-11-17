import SwiftUI

/// 00 · 첫 실행 화면 (Figma node 103:7588)
struct WelcomeView: View {
    let onStart: () -> Void

    /// Hero 영역(402x430 기준)의 구슬 배치: 감정, 크기, 좌상단 좌표, 블러(Figma 값)
    private let auras: [(emotion: Emotion, size: CGFloat, x: CGFloat, y: CGFloat, blur: CGFloat)] = [
        (.joy, 150, 150, 70, 2),
        (.achievement, 104, 40, 40, 1),
        (.stable, 100, 270, 30, 0.5),
        (.sad, 130, 250, 190, 1),
        (.fear, 120, 30, 190, 1.5),
        (.angry, 96, 149, 270, 3),
        (.exhausted, 64, 300, 330, 4),
    ]

    var body: some View {
        VStack(spacing: 0) {
            hero
                .padding(.top, 34)

            introText
                .padding(.top, 25)

            Spacer(minLength: 24)

            startButton
                .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(alignment: .topLeading) { background }
    }

    private var background: some View {
        ZStack(alignment: .topLeading) {
            FeeloColor.bgApp

            // Wash: 위쪽으로 번지는 기쁨 색 배경
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Emotion.joy.auraStart, Emotion.joy.auraEnd],
                        center: .center,
                        startRadius: 0,
                        endRadius: 260
                    )
                )
                .frame(width: 520, height: 520)
                .opacity(0.25)
                .blur(radius: 40)
                .offset(x: -60, y: -120)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var hero: some View {
        ZStack(alignment: .topLeading) {
            ForEach(auras.indices, id: \.self) { index in
                let aura = auras[index]
                heroOrb(aura.emotion, size: aura.size, blur: aura.blur)
                    .offset(x: aura.x, y: aura.y)
            }
        }
        .frame(width: 402, height: 430, alignment: .topLeading)
        .frame(maxWidth: .infinity)
    }

    /// 첫 실행 전용 구슬. 글로우를 위로 밀지 않고 같은 자리에 겹치며, 구슬마다 다른 블러를 준다.
    /// 공용 `EmotionAuraView`와 모양이 달라서 이 화면 안에만 둔다.
    private func heroOrb(_ emotion: Emotion, size: CGFloat, blur: CGFloat) -> some View {
        let orb = Circle()
            .fill(
                RadialGradient(
                    colors: [emotion.auraStart, emotion.auraEnd],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)

        return ZStack {
            orb.opacity(0.5).blur(radius: 3)
            orb
        }
        .blur(radius: blur)
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var introText: some View {
        VStack(spacing: 10) {
            Text("Feelo")
                .font(.system(size: 52, weight: .bold))
                .tracking(-1)
                .foregroundStyle(FeeloColor.textPrimary)

            Text("오늘의 감정을 색으로 남겨요")
                .font(.system(size: 22, weight: .bold))
                .tracking(-0.26)
                .foregroundStyle(FeeloColor.textPrimary)

            Text("짧게 쓰고 감정을 고르면,\n한 달이 색으로 이어져요.")
                .font(.system(size: 17))
                .tracking(-0.43)
                .lineSpacing(0)
                .multilineTextAlignment(.center)
                .foregroundStyle(FeeloColor.textSecondary)
        }
    }

    private var startButton: some View {
        Button(action: onStart) {
            Text("시작하기")
                .font(.system(size: 17, weight: .medium))
                .tracking(-0.43)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(FeeloColor.tint, in: Capsule())
        }
    }
}

#Preview {
    WelcomeView(onStart: {})
}
