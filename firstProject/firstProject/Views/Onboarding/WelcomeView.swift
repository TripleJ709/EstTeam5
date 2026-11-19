import SwiftUI

struct WelcomeView: View {
    let onStart: () -> Void

    private let auras: [HeroAura] = [
        HeroAura(emotion: .joy, size: 150, x: 150, y: 70, blur: 2),
        HeroAura(emotion: .achievement, size: 104, x: 40, y: 40, blur: 1),
        HeroAura(emotion: .stable, size: 100, x: 270, y: 30, blur: 0.5),
        HeroAura(emotion: .sad, size: 130, x: 250, y: 190, blur: 1),
        HeroAura(emotion: .fear, size: 120, x: 30, y: 190, blur: 1.5),
        HeroAura(emotion: .angry, size: 96, x: 149, y: 270, blur: 3),
        HeroAura(emotion: .exhausted, size: 64, x: 300, y: 330, blur: 4)
    ]

    @ScaledMetric(relativeTo: .largeTitle) private var logoSize = 52

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                    .padding(.top, 34)

                introText
                    .padding(.top, 25)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            startButton
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(FeeloColor.bgApp.ignoresSafeArea(edges: .bottom))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(alignment: .topLeading) { background }
    }

    private var background: some View {
        ZStack(alignment: .topLeading) {
            FeeloColor.bgApp

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
                heroOrb(aura.emotion, size: aura.size, blur: aura.blur)
                    .offset(x: aura.x, y: aura.y)
            }
        }
        .frame(width: 402, height: 430, alignment: .topLeading)
        .frame(maxWidth: .infinity)
    }

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
                .font(.system(size: logoSize, weight: .bold))
                .tracking(-1)
                .foregroundStyle(FeeloColor.textPrimary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text("오늘의 감정을 색으로 남겨요")
                .font(.title2.bold())
                .foregroundStyle(FeeloColor.textPrimary)

            Text("짧게 쓰고 감정을 고르면,\n한 달이 색으로 이어져요.")
                .font(.body)
                .lineSpacing(0)
                .multilineTextAlignment(.center)
                .foregroundStyle(FeeloColor.textSecondary)
        }
    }

    private var startButton: some View {
        Button(action: onStart) {
            Text("시작하기")
                .font(.body.weight(.medium))
                .foregroundStyle(FeeloColor.onTint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .frame(minHeight: 52)
                .background(FeeloColor.tint, in: Capsule())
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
