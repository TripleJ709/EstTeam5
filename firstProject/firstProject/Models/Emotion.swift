import SwiftUI

enum Emotion: String, CaseIterable, Identifiable {
    case joy
    case achievement
    case stable
    case angry
    case fear
    case sad
    case exhausted

    var id: String { rawValue }

    static let fallback: Emotion = .stable

    var displayName: String {
        switch self {
        case .joy: return "기쁨"
        case .achievement: return "성취"
        case .stable: return "안정"
        case .angry: return "분노"
        case .fear: return "두려움"
        case .sad: return "슬픔"
        case .exhausted: return "소진"
        }
    }

    var emoji: String {
        switch self {
        case .joy: return "😊"
        case .achievement: return "🏆"
        case .stable: return "😌"
        case .angry: return "😠"
        case .fear: return "😨"
        case .sad: return "😢"
        case .exhausted: return "😮‍💨"
        }
    }

    var colorName: String {
        switch self {
        case .joy: return "EmotionJoy"
        case .achievement: return "EmotionAchievement"
        case .stable: return "EmotionStable"
        case .angry: return "EmotionAngry"
        case .fear: return "EmotionFear"
        case .sad: return "EmotionSad"
        case .exhausted: return "EmotionExhausted"
        }
    }

    var color: Color { Color(colorName) }
}
