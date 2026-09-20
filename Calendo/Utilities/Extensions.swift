import SwiftUI
import UIKit

// MARK: - Glass Morphism View Modifier
struct GlassMorphismModifier: ViewModifier {
    var cornerRadius: CGFloat = CalendoDesign.cornerRadius

    func body(content: Content) -> some View {
        content
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func glassMorphism(cornerRadius: CGFloat = CalendoDesign.cornerRadius) -> some View {
        modifier(GlassMorphismModifier(cornerRadius: cornerRadius))
    }

    func calendoBackground() -> some View {
        self.background(CalendoDesign.backgroundGradient.ignoresSafeArea())
    }
}

// MARK: - Root View Controller (for Google Sign-In)
extension UIApplication {
    static var rootViewController: UIViewController? {
        guard let windowScene = shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return nil }
        return rootVC
    }
}

// MARK: - Date Formatting Helpers
extension Date {
    /// Format as Greek display date: "20 Σεπτεμβρίου 2026"
    var greekDateString: String {
        let formatter = DateFormatter()
        formatter.locale = AppConstants.greekLocale
        formatter.dateFormat = "d MMMM yyyy"
        formatter.timeZone = AppConstants.athensTimeZone
        return formatter.string(from: self)
    }

    /// Format as time: "14:30"
    var greekTimeString: String {
        let formatter = DateFormatter()
        formatter.locale = AppConstants.greekLocale
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = AppConstants.athensTimeZone
        return formatter.string(from: self)
    }

    /// Greeting based on time of day
    var greekGreeting: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 5..<12: return "Καλημέρα"
        case 12..<17: return "Καλό μεσημέρι"
        case 17..<21: return "Καλό απόγευμα"
        default: return "Καλησπέρα"
        }
    }
}

// MARK: - String Helpers
extension String {
    var isNotEmpty: Bool { !trimmingCharacters(in: .whitespaces).isEmpty }
}
