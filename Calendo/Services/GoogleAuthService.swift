import Foundation
import GoogleSignIn
import UIKit

@MainActor
@Observable
final class GoogleAuthService {
    var currentUser: GIDGoogleUser?
    var errorMessage: String?

    var isSignedIn: Bool { currentUser != nil }

    var userName: String {
        currentUser?.profile?.givenName ?? "Γιατρέ"
    }

    var userEmail: String {
        currentUser?.profile?.email ?? ""
    }

    // MARK: - Init & Restore
    init() {
        // Try to restore silently
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            Task { @MainActor [weak self] in
                if let user {
                    self?.currentUser = user
                }
            }
        }
    }

    // MARK: - Sign In with Calendar Scope
    func signIn() async throws {
        guard let rootVC = UIApplication.rootViewController else {
            throw AuthError.noRootViewController
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootVC,
                hint: nil,
                additionalScopes: [AppConstants.calendarScope]
            )
            self.currentUser = result.user
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }

    // MARK: - Get Calendar Access Token
    func getCalendarAccessToken() async throws -> String {
        guard let user = currentUser else {
            throw AuthError.notAuthenticated
        }

        // Check if calendar scope is granted
        let hasCalendarScope = user.grantedScopes?.contains(AppConstants.calendarScope) ?? false

        if !hasCalendarScope {
            // Request calendar scope
            guard let rootVC = UIApplication.rootViewController else {
                throw AuthError.noRootViewController
            }
            let result = try await user.addScopes([AppConstants.calendarScope], presenting: rootVC)
            if let updatedUser = result?.user {
                self.currentUser = updatedUser
                return updatedUser.accessToken.tokenString
            }
            // If result is non-optional in this SDK version, this handles both cases
            throw AuthError.scopeNotGranted
        }

        // Refresh token if needed
        do {
            let refreshedUser = try await user.refreshTokensIfNeeded()
            self.currentUser = refreshedUser
            return refreshedUser.accessToken.tokenString
        } catch {
            throw AuthError.tokenRefreshFailed(error.localizedDescription)
        }
    }

    // MARK: - Sign Out
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        currentUser = nil
        UserDefaults.standard.set(false, forKey: AppConstants.hasCompletedOnboarding)
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case noRootViewController
    case notAuthenticated
    case signInFailed(String)
    case scopeNotGranted
    case tokenRefreshFailed(String)

    var errorDescription: String? {
        switch self {
        case .noRootViewController:
            return "Δεν βρέθηκε παράθυρο εφαρμογής"
        case .notAuthenticated:
            return "Δεν είστε συνδεδεμένοι. Παρακαλώ συνδεθείτε ξανά."
        case .signInFailed(let msg):
            return "Σφάλμα σύνδεσης: \(msg)"
        case .scopeNotGranted:
            return "Δεν δόθηκε πρόσβαση στο ημερολόγιο"
        case .tokenRefreshFailed(let msg):
            return "Σφάλμα ανανέωσης: \(msg)"
        }
    }
}
