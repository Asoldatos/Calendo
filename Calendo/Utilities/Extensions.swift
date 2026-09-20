import SwiftUI
import UIKit

// MARK: - Glass Morphism View Modifier
struct GlassMorphismModifier: ViewModifier {
    var cornerRadius: CGFloat = CalendoDesign.cornerRadius

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

extension View {
    func glassMorphism(cornerRadius: CGFloat = CalendoDesign.cornerRadius) -> some View {
        modifier(GlassMorphismModifier(cornerRadius: cornerRadius))
    }

    func calendoBackground() -> some View {
        self.background(CalendoDesign.backgroundGradient.ignoresSafeArea())
    }

    /// Glass effect wrapper that falls back to ultraThinMaterial on older iOS
    @ViewBuilder
    func calendoGlass<S: InsettableShape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(.ultraThinMaterial, in: shape)
        }
    }
}

// MARK: - Root View Controller (for Google Sign-In)
extension UIApplication {
    @MainActor
    static var rootViewController: UIViewController? {
        // Find the active window scene
        let windowScene = shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first ?? shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
            
        // Find the key window or just the first window
        guard let window = windowScene?.windows.first(where: { $0.isKeyWindow }) ?? windowScene?.windows.first else {
            return nil
        }
        
        // Find the topmost view controller
        var topController = window.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
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
