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

// MARK: - App Entry Point
@main
struct CalendoApp: App {
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
