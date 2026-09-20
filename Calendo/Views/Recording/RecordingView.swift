import SwiftUI

struct RecordingView: View {
    @Binding var navigationPath: NavigationPath
    var appointmentData: AppointmentData
    @State private var viewModel: RecordingViewModel
    @State private var showError = false

    init(navigationPath: Binding<NavigationPath>, appointmentData: AppointmentData) {
        self._navigationPath = navigationPath
        self.appointmentData = appointmentData
        self._viewModel = State(initialValue: RecordingViewModel(appointmentData: appointmentData))
    }

    var body: some View {
        ZStack {
            CalendoDesign.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                header
                    .padding(.horizontal, CalendoDesign.screenPadding)
                    .padding(.top, 8)

                Spacer()

                // MARK: - Waveform / Mic Visualization
                microphoneVisualization

                Spacer().frame(height: 24)

                // MARK: - Live Transcription
                transcriptionSection
                    .padding(.horizontal, CalendoDesign.screenPadding)

                Spacer().frame(height: 20)

                // MARK: - Detected Fields
                detectedFieldsSection
                    .padding(.horizontal, CalendoDesign.screenPadding)

                Spacer()

                // MARK: - Action Buttons
                actionButtons
                    .padding(.horizontal, CalendoDesign.screenPadding)
                    .padding(.bottom, 32)
            }

            // Loading overlay
            if viewModel.isFinishing || viewModel.isParsing {
                Color.black.opacity(0.5).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Ανάλυση με AI...")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .padding(32)
                .calendoGlass(in: RoundedRectangle(cornerRadius: 20))
            }
        }
        .navigationBarHidden(true)
        .alert("Σφάλμα", isPresented: $showError) {
            Button("Εντάξει", role: .cancel) {}
        } message: {
            Text(viewModel.parseError ?? viewModel.speechService.errorMessage ?? "Άγνωστο σφάλμα")
        }
        .onChange(of: viewModel.parseError) { _, newVal in
            if newVal != nil { showError = true }
        }
        .task {
            await viewModel.startRecording()
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                viewModel.stopRecording()
                navigationPath.removeLast()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .calendoGlass(in: Circle())
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Νέο Ραντεβού")
                    .font(.headline)
                    .foregroundStyle(.white)

                if viewModel.speechService.isRecording {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                        Text("Εγγραφή...")
                            .font(.caption)
                            .foregroundStyle(.calendoCoral)
                    }
                }
            }

            Spacer()

            // Invisible spacer for centering
            Color.clear.frame(width: 40, height: 40)
        }
    }

    // MARK: - Microphone Visualization
    private var microphoneVisualization: some View {
        ZStack {
            // Pulse rings
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(Color.calendoPurple.opacity(0.15 - Double(i) * 0.04), lineWidth: 2)
                    .frame(width: CGFloat(160 + i * 50), height: CGFloat(160 + i * 50))
                    .scaleEffect(viewModel.speechService.isRecording ? 1.0 + CGFloat(viewModel.speechService.audioLevel) * 0.3 : 1.0)
                    .animation(.easeOut(duration: 0.15), value: viewModel.speechService.audioLevel)
            }

            // Center mic button
            ZStack {
                Circle()
                    .fill(viewModel.speechService.isRecording ? CalendoDesign.purpleGradient : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                    .frame(width: 120, height: 120)
                    .shadow(color: .calendoPurple.opacity(0.4), radius: 20)

                Image(systemName: viewModel.speechService.isRecording ? "waveform" : "mic.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
                    .symbolEffect(.variableColor.iterative, isActive: viewModel.speechService.isRecording)
            }

            // Waveform bars
            WaveformView(audioLevel: viewModel.speechService.audioLevel, isActive: viewModel.speechService.isRecording)
                .frame(height: 60)
                .padding(.horizontal, 40)
                .offset(y: 100)
        }
    }

    // MARK: - Transcription Display
    private var transcriptionSection: some View {
        VStack(spacing: 8) {
            Text("Μεταγραφή")
                .font(.caption.bold())
                .foregroundStyle(.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                Text(viewModel.speechService.transcription.isEmpty
                     ? "Μιλήστε για να καταγράψετε το ραντεβού...\n\nΠ.χ. \"Αύριο στις 3 ο Γιώργος Παπαδόπουλος από τέσσερις μέχρι τεσσερισήμισι\""
                     : viewModel.speechService.transcription)
                    .font(.body)
                    .foregroundStyle(viewModel.speechService.transcription.isEmpty ? .textTertiary : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxHeight: 100)
            .padding(16)
            .calendoGlass(in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Detected Fields Indicators
    private var detectedFieldsSection: some View {
        HStack(spacing: 12) {
            DetectionChip(
                icon: "calendar",
                label: "Ημερομηνία",
                detected: appointmentData.hasDate
            )
            DetectionChip(
                icon: "clock",
                label: "Ώρα",
                detected: appointmentData.hasTime
            )
            DetectionChip(
                icon: "person",
                label: "Ασθενής",
                detected: appointmentData.hasName
            )
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Instruction text
            Text("Πείτε ημερομηνία, ώρα και όνομα ασθενούς\nσε οποιαδήποτε σειρά")
                .font(.caption)
                .foregroundStyle(.textTertiary)
                .multilineTextAlignment(.center)

            // Finish Button
            Button {
                HapticManager.impact(.heavy)
                Task {
                    let nextScreen = await viewModel.finish()
                    navigationPath.append(nextScreen)
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Ολοκλήρωση")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(CalendoDesign.purpleGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .calendoPurple.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(viewModel.speechService.transcription.isEmpty)
            .opacity(viewModel.speechService.transcription.isEmpty ? 0.5 : 1.0)
        }
    }
}

// MARK: - Detection Chip
struct DetectionChip: View {
    let icon: String
    let label: String
    let detected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: detected ? "\(icon).circle.fill" : icon)
                .font(.title3)
                .foregroundStyle(detected ? .calendoTeal : .textTertiary)

            Text(label)
                .font(.caption2)
                .foregroundStyle(detected ? .calendoTeal : .textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .calendoGlass(in: RoundedRectangle(cornerRadius: 12))
        .animation(.spring(response: 0.4), value: detected)
    }
}
