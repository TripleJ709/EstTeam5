import SwiftData
import SwiftUI

/// 앱의 진입점입니다.
///
/// `Retrospective` 모델용 SwiftData 컨테이너를 연결하고, 환영 화면을 본 적이 있는지에 따라 `MainTabView` 또는 `WelcomeView`를 보여줍니다.
@main
struct firstProjectApp: App {
    /// 환영 화면을 이미 확인했는지 여부입니다. `UserDefaults`의 `hasSeenWelcome` 키에 저장됩니다.
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    /// 앱 테마 설정입니다. `UserDefaults`의 `appTheme` 키에 저장되며 기본값은 `.system`입니다.
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    /// 앱의 장면 구성입니다. 환영 화면 확인 여부에 따라 화면을 나누고, 선택한 테마의 `colorScheme`을 적용합니다.
    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenWelcome {
                    MainTabView()
                } else {
                    WelcomeView { hasSeenWelcome = true }
                }
            }
            .preferredColorScheme(appTheme.colorScheme)
        }
        .modelContainer(for: Retrospective.self)
    }
}
