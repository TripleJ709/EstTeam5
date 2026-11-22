import SwiftUI

/// 앱의 화면 테마 선택지입니다.
enum AppTheme: String, CaseIterable, Identifiable {
    /// 기기의 시스템 설정을 따릅니다.
    case system
    /// 라이트 모드를 사용합니다.
    case light
    /// 다크 모드를 사용합니다.
    case dark

    /// `rawValue`를 식별자로 사용합니다.
    var id: String { rawValue }

    /// 화면에 표시할 테마 이름입니다.
    var title: String {
        switch self {
        case .system: "시스템"
        case .light: "라이트"
        case .dark: "다크"
        }
    }

    /// 적용할 `ColorScheme`입니다. `system`은 `nil`이며, 나머지는 각각 `.light`, `.dark`입니다.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
