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

    var color: Color {
        switch self {
        case .joy: return .yellow
        case .achievement: return .orange
        case .stable: return .green
        case .angry: return .red
        case .fear: return .purple
        case .sad: return .blue
        case .exhausted: return .gray
        }
    }
}
