import SwiftUI

/// 앱의 화면 테마입니다. 선택한 값은 `@AppStorage("appTheme")`에 저장됩니다.
enum AppTheme: String, CaseIterable, Identifiable {
    /// 기기 설정을 따릅니다.
    case system
    /// 항상 라이트 모드로 보여 줍니다.
    case light
    /// 항상 다크 모드로 보여 줍니다.
    case dark

    var id: String { rawValue }

    /// 선택 화면에 보이는 테마 이름입니다.
    var title: String {
        switch self {
        case .system: "시스템"
        case .light: "라이트"
        case .dark: "다크"
        }
    }

    /// SwiftUI에 적용할 색 구성입니다. 시스템을 따를 때는 `nil`입니다.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
