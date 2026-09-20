import SwiftUI

// MARK: - App Constants
enum AppConstants {
    // Google Sign-In
    static let googleClientID = "718756612878-vgbmspg71o536u77bg42k3rkolm4gfnb.apps.googleusercontent.com"
    static let reversedClientID = "com.googleusercontent.apps.718756612878-vgbmspg71o536u77bg42k3rkolm4gfnb"

    // Google Calendar API
    static let calendarScope = "https://www.googleapis.com/auth/calendar.events"
    static let calendarBaseURL = "https://www.googleapis.com/calendar/v3/calendars/primary/events"

    // Gemini AI
    // ⚠️ Get your FREE API key from: https://aistudio.google.com/apikey
    static let geminiAPIKey = "AQ.Ab8RN6Ikxu7YbFfQdenJTq6iihQ0q_6dGfjhI38N6I5VjjbayA"
    static let geminiModel = "gemini-2.0-flash"

    // Localization
    static let greekLocale = Locale(identifier: "el-GR")
    static let athensTimeZone = TimeZone(identifier: "Europe/Athens")!

    // Quick Action
    static let recordShortcutType = "com.calendo.app.record"

    // UserDefaults Keys
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
}

// MARK: - Design System Colors
extension Color {
    // Primary palette (matches app icon purple theme)
    static let calendoPurple = Color(red: 0.42, green: 0.36, blue: 0.91)       // #6C5CE7
    static let calendoPurpleDark = Color(red: 0.30, green: 0.25, blue: 0.75)    // #4D40BF
    static let calendoCoral = Color(red: 0.96, green: 0.40, blue: 0.40)         // #F56565
    static let calendoTeal = Color(red: 0.00, green: 0.79, blue: 0.65)          // #00C9A7
    static let calendoGold = Color(red: 1.00, green: 0.82, blue: 0.25)          // #FFD140

    // Background gradients
    static let bgDark = Color(red: 0.04, green: 0.04, blue: 0.10)              // #0A0A1A
    static let bgMid = Color(red: 0.10, green: 0.10, blue: 0.18)              // #1A1A2E
    static let bgCard = Color(red: 0.14, green: 0.14, blue: 0.24)             // #24243D

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)
}

// MARK: - Design System
enum CalendoDesign {
    static let cornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 20
    static let screenPadding: CGFloat = 24

    static let backgroundGradient = LinearGradient(
        colors: [.bgDark, .bgMid],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let purpleGradient = LinearGradient(
        colors: [.calendoPurple, .calendoPurpleDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
