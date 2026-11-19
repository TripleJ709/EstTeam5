import SwiftUI

/// 앱의 화면 테마 선택지입니다.
enum AppTheme: String, CaseIterable, Identifiable {
    /// 기기 설정을 따릅니다.
    case system
    /// 라이트 모드입니다.
    case light
    /// 다크 모드입니다.
    case dark

    /// `Identifiable` 채택을 위한 식별자이며 원시값을 사용합니다.
    var id: String { rawValue }

    /// 화면에 표시하는 테마 이름입니다.
    var title: String {
        switch self {
        case .system: "시스템"
        case .light: "라이트"
        case .dark: "다크"
        }
    }

    /// 테마에 대응하는 `ColorScheme`입니다. `system`은 `nil`입니다.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
