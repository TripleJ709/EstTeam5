import SwiftData
import SwiftUI

/// 앱의 메인 탭 화면입니다.
///
/// 달력 탭(`RetrospectiveListView`)과 기록 탭(`StatisticsView`)으로 구성됩니다.
struct MainTabView: View {
    /// 화면 구성
    var body: some View {
        TabView {
            RetrospectiveListView()
                .tabItem { Label("달력", systemImage: "calendar") }

            StatisticsView()
                .tabItem { Label("기록", systemImage: "chart.bar") }
        }
        .tint(Color.tintPrimary)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Retrospective.self, inMemory: true)
}
