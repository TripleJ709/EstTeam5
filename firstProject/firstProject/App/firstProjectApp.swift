import SwiftData
import SwiftUI

/// 앱의 진입점입니다.
///
/// 환영 화면을 본 적이 있으면 `MainTabView`를, 없으면 `WelcomeView`를 보여주며 `Retrospective` 모델 컨테이너를 설정합니다.
@main
struct firstProjectApp: App {
    /// 환영 화면을 이미 확인했는지 여부입니다. `AppStorage`의 `hasSeenWelcome` 키에 저장됩니다.
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    /// 앱 테마 설정입니다. `AppStorage`의 `appTheme` 키에 저장되며 기본값은 `.system`입니다.
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    /// 앱의 씬 구성
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
