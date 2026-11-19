import SwiftUI

/// 앱 첫 실행 시 보여주는 환영 화면입니다.
struct WelcomeView: View {
    /// 시작 버튼을 눌렀을 때 호출되는 동작입니다.
    let onStart: () -> Void

    /// 히어로 영역에 배치할 오라의 감정, 크기, 위치, 블러 값 목록입니다.
    private let auras: [HeroAura] = [
        HeroAura(emotion: .joy, size: 150, x: 150, y: 70, blur: 2),
        HeroAura(emotion: .achievement, size: 104, x: 40, y: 40, blur: 1),
        HeroAura(emotion: .stable, size: 100, x: 270, y: 30, blur: 0.5),
        HeroAura(emotion: .sad, size: 130, x: 250, y: 190, blur: 1),
        HeroAura(emotion: .fear, size: 120, x: 30, y: 190, blur: 1.5),
        HeroAura(emotion: .angry, size: 96, x: 149, y: 270, blur: 3),
        HeroAura(emotion: .exhausted, size: 64, x: 300, y: 330, blur: 4)
    ]

    /// 로고 텍스트 크기이며 글자 크기 설정에 따라 조정됩니다.
    @ScaledMetric(relativeTo: .largeTitle) private var logoSize = 52

    /// 화면 구성
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

    /// 배경색과 감정 `joy`의 그라데이션 원으로 이루어진 배경입니다.
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

    /// 여러 감정 오라를 겹쳐 배치한 히어로 영역입니다.
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

    /// 앱 이름과 소개 문구를 보여주는 영역입니다.
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

    /// `onStart`를 실행하는 시작하기 버튼입니다.
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

/// 히어로 영역에 배치되는 오라 하나의 설정입니다.
private struct HeroAura: Identifiable {
    /// 표시할 감정입니다.
    let emotion: Emotion
    /// 오라 크기입니다.
    let size: CGFloat
    /// 가로 오프셋입니다.
    let x: CGFloat
    /// 세로 오프셋입니다.
    let y: CGFloat
    /// 블러 반경입니다.
    let blur: CGFloat

    /// 감정을 식별자로 사용합니다.
    var id: Emotion { emotion }
}

#Preview {
    WelcomeView(onStart: {})
}
