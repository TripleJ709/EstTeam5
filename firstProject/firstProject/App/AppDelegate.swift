import FirebaseAppCheck
import FirebaseCore
import UIKit

/// 앱이 켜질 때 Firebase를 준비하는 델리게이트입니다.
class AppDelegate: NSObject, UIApplicationDelegate {
    /// 앱 실행 준비가 끝나면 App Check를 먼저 설정하고 Firebase를 시작합니다.
    ///
    /// 시뮬레이터는 App Attest를 쓸 수 없어서 디버그 토큰을 사용합니다.
    ///
    /// - Parameters:
    ///   - application: 현재 앱입니다.
    ///   - launchOptions: 앱이 실행된 이유를 담은 정보입니다.
    /// - Returns: 항상 `true`입니다.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if targetEnvironment(simulator)
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(FeeloAppCheckFactory())
        #endif
        FirebaseApp.configure()
        return true
    }
}

/// 실제 기기에서 Apple의 App Attest로 진짜 Feelo 앱인지 증명하게 해 줍니다.
nonisolated class FeeloAppCheckFactory: NSObject, AppCheckProviderFactory {
    /// App Attest를 사용하는 App Check 제공자를 만듭니다.
    ///
    /// - Parameter app: Firebase 앱입니다.
    /// - Returns: App Attest 제공자입니다.
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppAttestProvider(app: app)
    }
}
