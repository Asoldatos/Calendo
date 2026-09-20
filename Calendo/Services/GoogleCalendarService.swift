import Foundation

// MARK: - Calendar API Models
struct CalendarEventRequest: Codable {
    let summary: String
    let start: EventDateTime
    let end: EventDateTime

    struct EventDateTime: Codable {
        let dateTime: String
        let timeZone: String
    }
}

struct CalendarEventResponse: Codable {
    let id: String?
    let htmlLink: String?
    let summary: String?
    let status: String?
}

// MARK: - Google Calendar Service
final class GoogleCalendarService {
    static let shared = GoogleCalendarService()
    private init() {}

    /// Creates a Google Calendar event
    /// - Parameters:
    ///   - accessToken: OAuth access token with calendar.events scope
    ///   - title: Event title (e.g., "ΓΙΩΡΓΟΣ ΠΑΠΑΔΟΠΟΥΛΟΣ 6912345678")
    ///   - startDate: Event start date/time
    ///   - endDate: Event end date/time
    /// - Returns: The created event's HTML link
    func createEvent(
        accessToken: String,
        title: String,
        startDate: Date,
        endDate: Date
    ) async throws -> String {
        guard let url = URL(string: AppConstants.calendarBaseURL) else {
            throw CalendarError.invalidURL
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        isoFormatter.timeZone = AppConstants.athensTimeZone

        let requestBody = CalendarEventRequest(
            summary: title,
            start: .init(
                dateTime: isoFormatter.string(from: startDate),
                timeZone: "Europe/Athens"
            ),
            end: .init(
                dateTime: isoFormatter.string(from: endDate),
                timeZone: "Europe/Athens"
            )
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CalendarError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Άγνωστο σφάλμα"
            throw CalendarError.httpError(statusCode: httpResponse.statusCode, body: errorBody)
        }

        let eventResponse = try JSONDecoder().decode(CalendarEventResponse.self, from: data)
        return eventResponse.htmlLink ?? eventResponse.id ?? "OK"
    }
}

// MARK: - Calendar Errors
enum CalendarError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, body: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Μη έγκυρο URL ημερολογίου"
        case .invalidResponse:
            return "Μη έγκυρη απάντηση από το Google Calendar"
        case .httpError(let code, let body):
            return "Σφάλμα HTTP \(code): \(body)"
        }
    }
}
