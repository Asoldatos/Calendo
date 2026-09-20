import Foundation

// MARK: - Gemini AI Response Model
struct ParsedAppointment: Codable {
    var patientName: String?
    var date: String?           // YYYY-MM-DD
    var startTime: String?      // HH:mm
    var endTime: String?        // HH:mm
    var durationMinutes: Int?
}

// MARK: - App State for Current Appointment
@Observable
class AppointmentData {
    var patientName: String?
    var dateString: String?         // YYYY-MM-DD from Gemini
    var startTimeString: String?    // HH:mm
    var endTimeString: String?      // HH:mm
    var durationMinutes: Int?
    var phoneNumber: String?
    var rawTranscription: String = ""

    // MARK: - Field Detection
    var hasName: Bool { !(patientName ?? "").trimmingCharacters(in: .whitespaces).isEmpty }
    var hasDate: Bool { !(dateString ?? "").trimmingCharacters(in: .whitespaces).isEmpty }
    var hasTime: Bool { !(startTimeString ?? "").trimmingCharacters(in: .whitespaces).isEmpty }
    var hasDuration: Bool {
        (durationMinutes != nil && durationMinutes! > 0) ||
        !(endTimeString ?? "").trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Minimum required fields to proceed (name + date + start time)
    var isReadyToFinish: Bool { hasName && hasDate && hasTime }

    // MARK: - Date Computation
    var startDate: Date? {
        guard let dateStr = dateString, let timeStr = startTimeString else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = AppConstants.athensTimeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: "\(dateStr) \(timeStr)")
    }

    var endDate: Date? {
        guard let start = startDate else { return nil }

        // Priority 1: Explicit end time from Gemini
        if let endStr = endTimeString, !endStr.isEmpty, let dateStr = dateString {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            formatter.timeZone = AppConstants.athensTimeZone
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let end = formatter.date(from: "\(dateStr) \(endStr)") {
                // Handle overnight: if end is before start, add 1 day
                return end > start ? end : end.addingTimeInterval(24 * 60 * 60)
            }
        }

        // Priority 2: Duration in minutes
        if let minutes = durationMinutes, minutes > 0 {
            return start.addingTimeInterval(TimeInterval(minutes * 60))
        }

        // No duration info - will need to ask user
        return nil
    }

    // MARK: - Event Title (FORMAT: PATIENT_NAME TELEPHONE)
    var eventTitle: String {
        var title = (patientName ?? "ΑΣΘΕΝΗΣ").uppercased()
        if let phone = phoneNumber, !phone.trimmingCharacters(in: .whitespaces).isEmpty {
            title += " \(phone)"
        }
        return title
    }

    // MARK: - Apply Parsed Data from Gemini
    func applyParsed(_ parsed: ParsedAppointment) {
        if let name = parsed.patientName, !name.trimmingCharacters(in: .whitespaces).isEmpty {
            patientName = name.trimmingCharacters(in: .whitespaces)
        }
        if let date = parsed.date, !date.trimmingCharacters(in: .whitespaces).isEmpty {
            dateString = date.trimmingCharacters(in: .whitespaces)
        }
        if let time = parsed.startTime, !time.trimmingCharacters(in: .whitespaces).isEmpty {
            startTimeString = time.trimmingCharacters(in: .whitespaces)
        }
        if let end = parsed.endTime, !end.trimmingCharacters(in: .whitespaces).isEmpty {
            endTimeString = end.trimmingCharacters(in: .whitespaces)
        }
        if let dur = parsed.durationMinutes, dur > 0 {
            durationMinutes = dur
        }
    }

    // MARK: - Reset
    func reset() {
        patientName = nil
        dateString = nil
        startTimeString = nil
        endTimeString = nil
        durationMinutes = nil
        phoneNumber = nil
        rawTranscription = ""
    }
}
