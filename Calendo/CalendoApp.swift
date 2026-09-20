import SwiftUI
import GoogleSignIn

// MARK: - Navigation State
enum AppScreen: Hashable {
    case recording
    case durationInput
    case phoneInput
    case processing
    case success
}

// MARK: - Quick Action Manager
@MainActor
@Observable
final class QuickActionManager {
    static let shared = QuickActionManager()

    var pendingAction: String?

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        if shortcutItem.type == AppConstants.recordShortcutType {
            pendingAction = shortcutItem.type
            return true
        }
        return false
    }
}

// MARK: - App Delegate (Quick Action handling)
class CalendoAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Cold start: handle shortcut item
        if let shortcutItem = options.shortcutItem {
            Task { @MainActor in
                _ = QuickActionManager.shared.handleShortcutItem(shortcutItem)
            }
        }

        let config = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        config.delegateClass = CalendoSceneDelegate.self
        return config
    }
}

// MARK: - Scene Delegate (Warm launch Quick Action)
class CalendoSceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        Task { @MainActor in
            let handled = QuickActionManager.shared.handleShortcutItem(shortcutItem)
            completionHandler(handled)
        }
    }
}

// MARK: - App Entry Point
@main
struct CalendoApp: App {
    @UIApplicationDelegateAdaptor(CalendoAppDelegate.self) var appDelegate
    @State private var authService = GoogleAuthService()
    @State private var quickActionManager = QuickActionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
                .environment(quickActionManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
