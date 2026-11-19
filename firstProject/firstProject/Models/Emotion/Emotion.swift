import SwiftUI

enum Emotion: String, CaseIterable, Identifiable, Decodable {
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

    var auraStart: Color { Color("\(rawValue)AuraStart") }
    var auraEnd: Color { Color("\(rawValue)AuraEnd") }
}
