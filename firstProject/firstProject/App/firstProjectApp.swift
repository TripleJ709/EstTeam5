import SwiftData
import SwiftUI

/// Feelo 앱의 시작점입니다.
///
/// 첫 실행에는 소개 화면(`WelcomeView`)을 보여 주고, 그 뒤로는 탭 화면(`MainTabView`)을 보여 줍니다.
/// 선택한 테마를 앱 전체에 적용하고, 회고(`Retrospective`)를 저장할 SwiftData 저장소를 만듭니다.
@main
struct firstProjectApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

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
