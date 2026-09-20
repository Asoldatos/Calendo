import UIKit

enum HapticManager {
    @MainActor
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    @MainActor
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    @MainActor
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // Convenience methods
    @MainActor static func success() { notification(.success) }
    @MainActor static func error() { notification(.error) }
    @MainActor static func warning() { notification(.warning) }
    @MainActor static func lightTap() { impact(.light) }
    @MainActor static func heavyTap() { impact(.heavy) }
}
