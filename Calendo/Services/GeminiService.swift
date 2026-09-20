import Foundation
import GoogleGenerativeAI

/// Gemini AI service for parsing Greek natural language into structured appointment data.
/// Uses Google Gemini Flash (free tier) for intelligent understanding of complex Greek expressions
/// like "από τέσσερις και μισή μέχρι δύο και είκοσι" or "αύριο στις 3 ο Γιώργος Παπαδόπουλος"
final class GeminiService: @unchecked Sendable {
    static let shared = GeminiService()

    private let model: GenerativeModel

    private init() {
        model = GenerativeModel(
            name: AppConstants.geminiModel,
            apiKey: AppConstants.geminiAPIKey,
            generationConfig: GenerationConfig(
                temperature: 0.1,
                maxOutputTokens: 500,
                responseMIMEType: "application/json"
            )
        )
    }

    // MARK: - Parse Full Appointment from Voice Transcription

    /// Parses free-form Greek text into structured appointment data
    /// The AI handles any order, informal expressions, and complex time formats
    func parseAppointment(text: String) async throws -> ParsedAppointment {
        let today = Self.todayString()

        let prompt = """
        Είσαι βοηθός ιατρείου. Ανάλυσε το παρακάτω κείμενο που ελήφθη από φωνητική εντολή στα Ελληνικά \
        και εξήγαγε τα στοιχεία ραντεβού.

        Σημερινή ημερομηνία: \(today)

        Κείμενο: "\(text)"

        Κανόνες:
        1. Αν αναφέρει "σήμερα", χρησιμοποίησε τη σημερινή ημερομηνία.
        2. Αν αναφέρει "αύριο", πρόσθεσε 1 ημέρα.
        3. Αν αναφέρει "μεθαύριο", πρόσθεσε 2 ημέρες.
        4. Αν αναφέρει ημέρα (π.χ. "Δευτέρα"), βρες την επόμενη εμφάνιση.
        5. Αν λέει "από X μέχρι/ως Y", τότε startTime=X και endTime=Y.
        6. Αν λέει "για X ώρα/λεπτά", τότε βάλε durationMinutes.
        7. Ώρες χωρίς πμ/μμ: αν είναι 1-7 θεώρησε μμ (πρόσθεσε 12), αν 8-12 θεώρησε πμ.
        8. Ονόματα ασθενών: βρες ελληνικά ονόματα/επώνυμα στο κείμενο.
        9. Αν δεν βρεις κάποιο στοιχείο, βάλε null.
        10. Οι ώρες πρέπει να είναι σε 24ωρη μορφή.

        Απάντησε ΜΟΝΟ με JSON σε αυτή τη μορφή:
        {
          "patientName": "string ή null",
          "date": "YYYY-MM-DD ή null",
          "startTime": "HH:mm ή null",
          "endTime": "HH:mm ή null",
          "durationMinutes": number ή null
        }
        """

        let response = try await model.generateContent(prompt)

        guard let responseText = response.text else {
            throw GeminiError.emptyResponse
        }

        return try parseJSON(responseText)
    }

    // MARK: - Parse Duration from User Input

    /// Parses a free-form Greek duration text into minutes
    /// Handles: "μισή ώρα", "45 λεπτά", "μιάμιση ώρα", "ένα τέταρτο", etc.
    func parseDuration(text: String) async throws -> ParsedDurationResult {
        let prompt = """
        Ο χρήστης περιγράφει τη διάρκεια ενός ιατρικού ραντεβού στα Ελληνικά.

        Κείμενο: "\(text)"

        Μετέτρεψε τη διάρκεια σε λεπτά. Παραδείγματα:
        - "μισή ώρα" → 30
        - "μία ώρα" → 60
        - "45 λεπτά" → 45
        - "μιάμιση ώρα" → 90
        - "ένα τέταρτο" → 15
        - "20 λεπτά" → 20
        - "δύο ώρες" → 120
        - "από 4:30 μέχρι 5:00" → 30 (και startTime/endTime)

        Αν ο χρήστης δώσει ώρες αντί διάρκεια (π.χ. "από 4:30 μέχρι 5:00"), υπολόγισε τη διάρκεια.

        Απάντησε ΜΟΝΟ με JSON:
        {
          "durationMinutes": number,
          "startTime": "HH:mm ή null",
          "endTime": "HH:mm ή null"
        }
        """

        let response = try await model.generateContent(prompt)

        guard let responseText = response.text else {
            throw GeminiError.emptyResponse
        }

        return try parseDurationJSON(responseText)
    }

    // MARK: - Private Helpers

    private func parseJSON(_ text: String) throws -> ParsedAppointment {
        // Clean the response - sometimes Gemini wraps in markdown code blocks
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw GeminiError.invalidJSON
        }

        do {
            return try JSONDecoder().decode(ParsedAppointment.self, from: data)
        } catch {
            throw GeminiError.parsingFailed(error.localizedDescription)
        }
    }

    private func parseDurationJSON(_ text: String) throws -> ParsedDurationResult {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw GeminiError.invalidJSON
        }

        do {
            return try JSONDecoder().decode(ParsedDurationResult.self, from: data)
        } catch {
            throw GeminiError.parsingFailed(error.localizedDescription)
        }
    }

    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = AppConstants.athensTimeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
}

// MARK: - Duration Result Model
struct ParsedDurationResult: Codable {
    let durationMinutes: Int
    let startTime: String?
    let endTime: String?
}

// MARK: - Gemini Errors
enum GeminiError: LocalizedError {
    case emptyResponse
    case invalidJSON
    case parsingFailed(String)

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "Κενή απάντηση από το AI"
        case .invalidJSON:
            return "Μη έγκυρη μορφή απάντησης"
        case .parsingFailed(let msg):
            return "Σφάλμα ανάλυσης: \(msg)"
        }
    }
}
