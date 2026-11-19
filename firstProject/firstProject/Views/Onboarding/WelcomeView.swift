import SwiftUI

struct WelcomeView: View {
    let onStart: () -> Void

    private let auras: [HeroAura] = [
        HeroAura(emotion: .joy, size: 195, x: 128, y: 48, blur: 2),
        HeroAura(emotion: .achievement, size: 135, x: 25, y: 25, blur: 1),
        HeroAura(emotion: .stable, size: 130, x: 255, y: 15, blur: 0.5),
        HeroAura(emotion: .sad, size: 169, x: 231, y: 171, blur: 1),
        HeroAura(emotion: .fear, size: 156, x: 12, y: 172, blur: 1.5),
        HeroAura(emotion: .angry, size: 125, x: 135, y: 256, blur: 3),
        HeroAura(emotion: .exhausted, size: 83, x: 291, y: 321, blur: 4)
    ]

    @ScaledMetric(relativeTo: .largeTitle) private var logoSize = 52

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                    .padding(.top, 34)

                introText
                    .padding(.top, 22)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            startButton
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(Color.bgApp.ignoresSafeArea(edges: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(alignment: .topLeading) { background }
    }

    private var background: some View {
        ZStack(alignment: .topLeading) {
            Color.bgApp

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
            ForEach(auras) { aura in
                EmotionAuraView(emotion: aura.emotion, size: aura.size)
                    .blur(radius: aura.blur)
                    .offset(x: aura.x, y: aura.y)
            }
        }
        .frame(width: 402, height: 430, alignment: .topLeading)
        .frame(maxWidth: .infinity)
    }

    private var introText: some View {
        VStack(spacing: 10) {
            Text("Feelo")
                .font(.system(size: logoSize, weight: .bold))
                .tracking(-1)
                .foregroundStyle(Color.textPrimary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text("오늘의 감정을 색으로 남겨요")
                .font(.title2.bold())
                .foregroundStyle(Color.textPrimary)

            Text("짧게 쓰고 감정을 고르면,\n한 달이 색으로 이어져요.")
                .font(.body)
                .lineSpacing(0)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var startButton: some View {
        Button(action: onStart) {
            Text("시작하기")
                .font(.body.weight(.medium))
                .foregroundStyle(Color.tintOnPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .frame(minHeight: 52)
                .background(Color.tintPrimary, in: Capsule())
        }
    }
}

private struct HeroAura: Identifiable {
    let emotion: Emotion
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    let blur: CGFloat

    var id: Emotion { emotion }
}

#Preview {
    WelcomeView(onStart: {})
}
