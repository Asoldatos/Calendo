import Foundation
import Speech
import AVFoundation

@Observable
final class SpeechRecognitionService {
    // MARK: - Published State
    var isRecording = false
    var transcription = ""
    var audioLevel: Float = 0.0
    var errorMessage: String?
    var isAuthorized = false

    // MARK: - Private Properties
    private let recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var levelTimer: Timer?

    init() {
        self.recognizer = SFSpeechRecognizer(locale: AppConstants.greekLocale)
    }

    // MARK: - Permission Request
    @MainActor
    func requestPermission() async -> Bool {
        // Request speech recognition permission
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        guard speechStatus == .authorized else {
            errorMessage = "Η αναγνώριση ομιλίας δεν εγκρίθηκε"
            return false
        }

        // Request microphone permission
        let micGranted: Bool
        if #available(iOS 17.0, *) {
            micGranted = await AVAudioApplication.requestRecordPermission()
        } else {
            micGranted = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }

        guard micGranted else {
            errorMessage = "Η πρόσβαση στο μικρόφωνο δεν εγκρίθηκε"
            return false
        }

        isAuthorized = true
        return true
    }

    // MARK: - Start Recording
    @MainActor
    func startRecording() throws {
        // Cancel any ongoing task
        stopRecording()

        guard let recognizer, recognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable
        }

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else {
            throw SpeechError.requestCreationFailed
        }

        request.shouldReportPartialResults = true
        request.addsPunctuation = true

        // Use on-device recognition if available (for privacy & speed)
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        // Start recognition task
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result {
                Task { @MainActor in
                    self.transcription = result.bestTranscription.formattedString
                }
            }

            if let error {
                Task { @MainActor in
                    // Don't report cancellation errors
                    if (error as NSError).code != 216 { // kAFAssistantErrorDomain cancel
                        self.errorMessage = error.localizedDescription
                    }
                    self.stopRecording()
                }
            }
        }

        // Install audio tap
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            // Calculate audio level for visualization
            self?.processAudioLevel(buffer: buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
        transcription = ""
    }

    // MARK: - Stop Recording
    @MainActor
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        audioLevel = 0.0
        levelTimer?.invalidate()
        levelTimer = nil

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Audio Level Processing
    private func processAudioLevel(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frames = buffer.frameLength

        var sum: Float = 0
        for i in 0..<Int(frames) {
            sum += abs(channelData[i])
        }
        let average = sum / Float(frames)

        // Normalize to 0...1 range with some amplification
        let normalizedLevel = min(1.0, average * 5.0)

        Task { @MainActor in
            self.audioLevel = normalizedLevel
        }
    }
}

// MARK: - Speech Errors
enum SpeechError: LocalizedError {
    case recognizerUnavailable
    case requestCreationFailed
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            return "Η αναγνώριση ομιλίας στα Ελληνικά δεν είναι διαθέσιμη"
        case .requestCreationFailed:
            return "Αποτυχία δημιουργίας αιτήματος αναγνώρισης"
        case .notAuthorized:
            return "Δεν έχετε δώσει άδεια για αναγνώριση ομιλίας"
        }
    }
}
