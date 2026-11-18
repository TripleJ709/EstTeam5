import SwiftUI

enum FeeloColor {
    static let bgApp = Color(hex: 0xF7F3EE)
    static let bgCard = Color.white
    static let bgSelected = Color(hex: 0xE9E5F3)
    static let textPrimary = Color(hex: 0x232946)
    static let textSecondary = Color(hex: 0x6B6880)
    static let tint = Color(hex: 0x232946)
    static let borderDashed = Color(hex: 0xC9C3D9)
    static let destructive = Color(hex: 0xFF383C)
}

enum FeeloRadius {
    static let cell: CGFloat = 14
    static let control: CGFloat = 20
    static let card: CGFloat = 26
    static let calendar: CGFloat = 28
    static let summary: CGFloat = 24
    static let chart : CGFloat = 28
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension Emotion {
    var auraStart: Color {
        switch self {
        case .joy: Color(hex: 0xFFE066)
        case .achievement: Color(hex: 0xFFB86B)
        case .stable: Color(hex: 0x8CE99A)
        case .angry: Color(hex: 0xFF8787)
        case .fear: Color(hex: 0xC3A6FF)
        case .sad: Color(hex: 0x8EC5FF)
        case .exhausted: Color(hex: 0xCED4DA)
        }
    }

    var auraEnd: Color {
        switch self {
        case .joy: Color(hex: 0xFFC43D)
        case .achievement: Color(hex: 0xFF8A3D)
        case .stable: Color(hex: 0x38C98A)
        case .angry: Color(hex: 0xF03E3E)
        case .fear: Color(hex: 0x8E5CF7)
        case .sad: Color(hex: 0x3D7BFA)
        case .exhausted: Color(hex: 0x8E959E)
        }
    }
}
