import SwiftUI

struct EmotionAuraView: View {
    let emotion: Emotion
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
