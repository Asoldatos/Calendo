import SwiftUI

/// Duration input chatbox — shown when the user didn't specify how long the appointment lasts.
/// The user types the duration in their own words in Greek (e.g. "μισή ώρα", "45 λεπτά",
/// "από 4:30 μέχρι 5:00") and Gemini AI parses it.
struct DurationInputView: View {
    @Binding var navigationPath: NavigationPath
    var appointmentData: AppointmentData
    @State private var durationText = ""
    @State private var isParsing = false
    @State private var errorMessage: String?
    @State private var showError = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            CalendoDesign.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.horizontal, CalendoDesign.screenPadding)
                    .padding(.top, 8)

                Spacer()

                // Main Content
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.calendoGold.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "clock.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.calendoGold)
                    }

                    // Title
                    VStack(spacing: 8) {
                        Text("Διάρκεια Ραντεβού")
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text("Πόσο διαρκεί το ραντεβού;\nΓράψτε στα δικά σας λόγια.")
                            .font(.subheadline)
                            .foregroundStyle(.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Summary of what was captured
                    capturedSummary

                    // Text Input
                    VStack(spacing: 8) {
                        TextField("π.χ. μισή ώρα, 45 λεπτά, από 4 μέχρι 5...", text: $durationText)
                            .font(.body)
                            .foregroundStyle(.white)
                            .padding(16)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
                            .focused($isTextFieldFocused)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .onSubmit { parseDuration() }

                        // Example chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ExampleChip(text: "μισή ώρα") { durationText = "μισή ώρα" }
                                ExampleChip(text: "45 λεπτά") { durationText = "45 λεπτά" }
                                ExampleChip(text: "1 ώρα") { durationText = "1 ώρα" }
                                ExampleChip(text: "20 λεπτά") { durationText = "20 λεπτά" }
                                ExampleChip(text: "μιάμιση ώρα") { durationText = "μιάμιση ώρα" }
                            }
                        }
                    }
                    .padding(.horizontal, CalendoDesign.screenPadding)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    // Done button
                    Button {
                        parseDuration()
                    } label: {
                        HStack(spacing: 10) {
                            if isParsing {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(isParsing ? "Ανάλυση..." : "Συνέχεια")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(durationText.isEmpty ? Color.gray : CalendoDesign.purpleGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(durationText.isEmpty || isParsing)

                    // Skip button
                    Button {
                        HapticManager.lightTap()
                        // Default to 30 minutes if skipped
                        appointmentData.durationMinutes = 30
                        navigationPath.append(AppScreen.phoneInput)
                    } label: {
                        Text("Παράλειψη (30 λεπτά)")
                            .font(.subheadline)
                            .foregroundStyle(.textSecondary)
                    }
                }
                .padding(.horizontal, CalendoDesign.screenPadding)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .alert("Σφάλμα", isPresented: $showError) {
            Button("Εντάξει", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Δοκιμάστε ξανά")
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                navigationPath.removeLast()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .glassEffect(.regular, in: Circle())
            }

            Spacer()

            Text("Διάρκεια")
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
    }

    // MARK: - Captured Summary
    private var capturedSummary: some View {
        HStack(spacing: 16) {
            if appointmentData.hasName {
                Label(appointmentData.patientName ?? "", systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.calendoTeal)
            }
            if appointmentData.hasDate {
                Label(appointmentData.dateString ?? "", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.calendoTeal)
            }
            if appointmentData.hasTime {
                Label(appointmentData.startTimeString ?? "", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.calendoTeal)
            }
        }
        .padding(12)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, CalendoDesign.screenPadding)
    }

    // MARK: - Parse Duration
    private func parseDuration() {
        guard !durationText.isEmpty else { return }
        HapticManager.impact(.medium)
        isParsing = true
        errorMessage = nil

        Task {
            do {
                let result = try await GeminiService.shared.parseDuration(text: durationText)
                appointmentData.durationMinutes = result.durationMinutes

                // If Gemini also detected start/end times, apply them
                if let start = result.startTime, !start.isEmpty, !appointmentData.hasTime {
                    appointmentData.startTimeString = start
                }
                if let end = result.endTime, !end.isEmpty {
                    appointmentData.endTimeString = end
                }

                HapticManager.success()
                navigationPath.append(AppScreen.phoneInput)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                HapticManager.error()
            }
            isParsing = false
        }
    }
}

// MARK: - Example Chip
struct ExampleChip: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .foregroundStyle(.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: Capsule())
        }
    }
}
