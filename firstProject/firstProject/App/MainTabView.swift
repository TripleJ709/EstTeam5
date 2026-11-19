import SwiftData
import SwiftUI

/// 앱의 메인 탭 화면입니다.
///
/// '회고' 탭에는 `RetrospectiveListView`, '통계' 탭에는 `StatisticsView`를 보여줍니다.
struct MainTabView: View {
    /// 화면 구성입니다.
    var body: some View {
        TabView {
            RetrospectiveListView()
                .tabItem { Label("회고", systemImage: "calendar") }

            StatisticsView()
                .tabItem { Label("통계", systemImage: "chart.bar") }
        }
        .tint(Color.tintPrimary)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
