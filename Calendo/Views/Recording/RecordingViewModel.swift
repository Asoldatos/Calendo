import Foundation

@MainActor
@Observable
final class RecordingViewModel {
    // MARK: - State
    var appointmentData: AppointmentData
    var speechService = SpeechRecognitionService()
    var isParsing = false
    var parseError: String?
    var isFinishing = false

    init(appointmentData: AppointmentData) {
        self.appointmentData = appointmentData
    }

    // MARK: - Start Recording
    func startRecording() async {
        let authorized = await speechService.requestPermission()
        guard authorized else { return }

        do {
            try speechService.startRecording()
        } catch {
            speechService.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Stop & Parse
    func stopRecording() {
        speechService.stopRecording()
    }

    // MARK: - Parse Transcription with Gemini AI
    func parseTranscription() async {
        let text = speechService.transcription
        guard !text.isEmpty else {
            parseError = "Δεν αναγνωρίστηκε κείμενο. Δοκιμάστε ξανά."
            return
        }

        appointmentData.rawTranscription = text
        isParsing = true
        parseError = nil

        do {
            let parsed = try await GeminiService.shared.parseAppointment(text: text)
            appointmentData.applyParsed(parsed)
            isParsing = false
        } catch {
            isParsing = false
            parseError = "Σφάλμα AI: \(error.localizedDescription)"
        }
    }

    // MARK: - Finish Recording Flow
    func finish() async -> AppScreen {
        isFinishing = true
        stopRecording()
        await parseTranscription()
        isFinishing = false

        // Determine next screen
        if !appointmentData.hasDuration {
            return .durationInput
        }
        return .phoneInput
    }

    // MARK: - Reset
    func reset() {
        speechService.transcription = ""
        speechService.errorMessage = nil
        parseError = nil
        isParsing = false
        isFinishing = false
    }
}
