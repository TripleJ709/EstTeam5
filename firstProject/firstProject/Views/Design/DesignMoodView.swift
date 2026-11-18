import SwiftUI

struct DesignMoodView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let keywords: [MoodKeyword] = [
        .init(title: "포근한", english: "Cozy", description: "크림 배경, 큰 모서리(카드 26pt), 그림자 대신 옅은 면 대비"),
        .init(title: "말랑한", english: "Soft", description: "각진 선 없이 원·캡슐 중심, 감정은 번지는 구슬 형태"),
        .init(title: "차분한", english: "Calm", description: "브랜드 색은 무채색 잉크, 정보 위계는 굵기와 크기로"),
        .init(title: "색으로 읽는", english: "Chromatic", description: "한 달이 색의 흐름으로 읽히도록 감정 색만 채도를 가짐"),
        .init(title: "가벼운", english: "Light", description: "짧게 쓰고 바로 닫는 흐름, 여백 넉넉히, 한 화면 한 목적"),
    ]

    private var isWide: Bool { sizeClass == .regular }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("01  디자인 키워드 & 무드")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(FeeloColor.textSecondary)

                Text("감정이 주인공이 되는, 포근하고 말랑한 하루 기록")
                    .font(.largeTitle.bold())
                    .foregroundStyle(FeeloColor.textPrimary)

                Text("Feelo는 브랜드 색을 잉크·크림 같은 차분한 무채색으로 낮추고, 화면의 색은 오직 '그날의 감정'에게 양보합니다. 감정은 단색 점이 아니라 부드럽게 번지는 아우라(그라데이션 구슬)로 표현해, 한 달 달력을 열었을 때 색이 은은하게 흐르는 일기장처럼 보이도록 합니다.")
                    .font(.callout)
                    .lineSpacing(6)
                    .foregroundStyle(FeeloColor.textSecondary)

                if isWide {
                    HStack(alignment: .top, spacing: 24) {
                        keywordList
                        MoodAuraCard()
                            .frame(width: 620)
                    }
                } else {
                    VStack(spacing: 24) {
                        keywordList
                        MoodAuraCard()
                    }
                }
            }
            .padding(.horizontal, isWide ? 64 : 20)
            .padding(.top, isWide ? 56 : 24)
            .padding(.bottom, isWide ? 64 : 32)
        }
        .background(FeeloColor.bgApp.ignoresSafeArea())
    }

    private var keywordList: some View {
        VStack(spacing: 12) {
            ForEach(keywords) { keyword in
                KeywordRow(keyword: keyword)
            }
        }
    }
}

private struct MoodKeyword: Identifiable {
    let title: String
    let english: String
    let description: String
    var id: String { english }
}

private struct KeywordRow: View {
    let keyword: MoodKeyword

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 0) {
                Text(keyword.title)
                    .font(.title2.bold())
                    .foregroundStyle(FeeloColor.textPrimary)
                Text(keyword.english)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(FeeloColor.textSecondary)
            }
            .frame(width: 150, alignment: .leading)

            Text(keyword.description)
                .font(.subheadline)
                .foregroundStyle(FeeloColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(FeeloColor.bgCard, in: RoundedRectangle(cornerRadius: FeeloRadius.card))
        .accessibilityElement(children: .combine)
    }
}

private struct MoodAuraCard: View {
    private static let designSize = CGSize(width: 620, height: 440)

    private struct Aura: Identifiable {
        let emotion: Emotion
        let diameter: CGFloat
        let origin: CGPoint
        var id: Emotion { emotion }
    }

    private let auras: [Aura] = [
        .init(emotion: .joy, diameter: 210, origin: .init(x: 40, y: 40)),
        .init(emotion: .achievement, diameter: 170, origin: .init(x: 230, y: 20)),
        .init(emotion: .stable, diameter: 200, origin: .init(x: 380, y: 90)),
        .init(emotion: .angry, diameter: 180, origin: .init(x: 90, y: 220)),
        .init(emotion: .fear, diameter: 220, origin: .init(x: 260, y: 200)),
        .init(emotion: .sad, diameter: 150, origin: .init(x: 430, y: 260)),
        .init(emotion: .exhausted, diameter: 120, origin: .init(x: 20, y: 330)),
    ]

    var body: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / Self.designSize.width
            ZStack(alignment: .topLeading) {
                ForEach(auras) { aura in
                    EmotionAuraBall(emotion: aura.emotion, diameter: aura.diameter)
                        .frame(width: aura.diameter, height: aura.diameter)
                        .offset(x: aura.origin.x, y: aura.origin.y)
                        .accessibilityHidden(true)
                }

                Text("감정 아우라 · Mood")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(FeeloColor.textPrimary)
                    .offset(x: 28, y: 396)
            }
            .frame(width: Self.designSize.width, height: Self.designSize.height, alignment: .topLeading)
            .scaleEffect(scale, anchor: .topLeading)
        }
        .aspectRatio(Self.designSize.width / Self.designSize.height, contentMode: .fit)
        .background(FeeloColor.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

private struct EmotionAuraBall: View {
    let emotion: Emotion
    let diameter: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: emotion.auraStart, location: 0),
                        .init(color: emotion.auraEnd.opacity(0.95), location: 0.55),
                        .init(color: emotion.auraEnd.opacity(0), location: 1),
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: diameter / 2
                )
            )
            .opacity(0.85)
            .blur(radius: 14)
    }
}

#Preview("Compact") {
    DesignMoodView()
}

#Preview("Regular", traits: .fixedLayout(width: 1280, height: 720)) {
    DesignMoodView()
        .environment(\.horizontalSizeClass, .regular)
}
