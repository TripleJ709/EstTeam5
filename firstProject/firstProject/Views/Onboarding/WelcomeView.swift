import SwiftUI

struct WelcomeView: View {
    let onStart: () -> Void

    // Figma(402×341) 기준 좌표. frame은 글로우 여백(×1.3)을 포함한 크기.
    private let auras: [HeroAura] = [
        HeroAura(emotion: .joy, x: 139.28, y: 59.25, frame: 177.049),
        HeroAura(emotion: .achievement, x: 57.57, y: 43.82, frame: 108.953),
        HeroAura(emotion: .stable, x: 302.71, y: 100.11, frame: 78.083),
        HeroAura(emotion: .sad, x: 122.49, y: 200.44, frame: 96.242),
        HeroAura(emotion: .fear, x: 21.25, y: 138.24, frame: 123.48),
        HeroAura(emotion: .angry, x: 268.66, y: 162.31, frame: 112.585),
        HeroAura(emotion: .exhausted, x: 213.28, y: 216.78, frame: 72.636)
    ]

    private let glowScale: CGFloat = 1.3

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                introText
                    .padding(.top, 94)
                    .padding(.horizontal, 24)

                hero
                    .padding(.top, 102)
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
                let size = aura.frame / glowScale
                let inset = (aura.frame - size) / 2

                EmotionAuraView(emotion: aura.emotion, size: size)
                    .offset(x: aura.x + inset, y: aura.y + inset)
            }

            Image("questionMark")
                .resizable()
                .frame(width: 29.087, height: 47.71)
                .foregroundStyle(Color.textPrimary)
                .offset(x: 124.72, y: 145.64)

            Image("exclamationMark")
                .resizable()
                .frame(width: 14.208, height: 61.275)
                .foregroundStyle(Color.textPrimary)
                .offset(x: 293.63, y: 57.44)
        }
        .frame(width: 402, height: 341, alignment: .topLeading)
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private var introText: some View {
        VStack(spacing: 10) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 46)
                .accessibilityLabel("Feelo")

            Text("오늘의 감정을 색으로 남겨요")
                .font(.title2.bold())
                .tracking(-0.26)
                .foregroundStyle(Color.textPrimary)

            Text("짧게 쓰고 감정을 고르면,\n한 달이 색으로 이어져요.")
                .font(.body)
                .tracking(-0.43)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var startButton: some View {
        Button(action: onStart) {
            Text("시작하기")
                .font(.body.weight(.medium))
                .tracking(-0.43)
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
    let x: CGFloat
    let y: CGFloat
    let frame: CGFloat

    var id: Emotion { emotion }
}

#Preview {
    WelcomeView(onStart: {})
}
