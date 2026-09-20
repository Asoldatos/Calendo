import SwiftUI

/// Processing screen — creates the Google Calendar event and shows success/failure.
struct ProcessingView: View {
    @Environment(GoogleAuthService.self) private var authService
    @Binding var navigationPath: NavigationPath
    var appointmentData: AppointmentData

    @State private var state: ProcessingState = .processing
    @State private var eventLink: String?
    @State private var errorMessage: String?
    @State private var animateCheck = false

    enum ProcessingState {
        case processing
        case success
        case error
    }

    var body: some View {
        ZStack {
            CalendoDesign.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Status Icon
                statusIcon

                // Status Text
                statusText

                // Event Details (on success)
                if state == .success {
                    eventDetailsCard
                        .transition(.scale.combined(with: .opacity))
                }

                // Error details
                if state == .error {
                    errorCard
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                // Action Button
                if state != .processing {
                    actionButton
                        .padding(.horizontal, CalendoDesign.screenPadding)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer().frame(height: 40)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: state)
        }
        .navigationBarHidden(true)
        .interactiveDismissDisabled(state == .processing)
        .task {
            await createEvent()
        }
    }

    // MARK: - Status Icon
    @ViewBuilder
    private var statusIcon: some View {
        switch state {
        case .processing:
            ZStack {
                Circle()
                    .fill(Color.calendoPurple.opacity(0.15))
                    .frame(width: 120, height: 120)

                ProgressView()
                    .scaleEffect(2.0)
                    .tint(.calendoPurple)
            }

        case .success:
            ZStack {
                Circle()
                    .fill(Color.calendoTeal.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.calendoTeal)
                    .scaleEffect(animateCheck ? 1.0 : 0.3)
                    .opacity(animateCheck ? 1.0 : 0.0)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    animateCheck = true
                }
            }

        case .error:
            ZStack {
                Circle()
                    .fill(Color.calendoCoral.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.calendoCoral)
            }
        }
    }

    // MARK: - Status Text
    @ViewBuilder
    private var statusText: some View {
        switch state {
        case .processing:
            VStack(spacing: 8) {
                Text("Δημιουργία ραντεβού...")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Καταχώρηση στο Google Calendar")
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }

        case .success:
            VStack(spacing: 8) {
                Text("Επιτυχία! 🎉")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Το ραντεβού καταχωρήθηκε")
                    .font(.subheadline)
                    .foregroundStyle(.calendoTeal)
            }

        case .error:
            VStack(spacing: 8) {
                Text("Σφάλμα")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Δεν ήταν δυνατή η δημιουργία")
                    .font(.subheadline)
                    .foregroundStyle(.calendoCoral)
            }
        }
    }

    // MARK: - Event Details Card
    private var eventDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Event title
            HStack(spacing: 10) {
                Image(systemName: "person.fill")
                    .foregroundStyle(.calendoPurple)
                Text(appointmentData.eventTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            Divider().overlay(Color.white.opacity(0.1))

            // Date & Time
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.calendoTeal)
                    Text(appointmentData.dateString ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .foregroundStyle(.calendoGold)
                    Text("\(appointmentData.startTimeString ?? "") → \(appointmentData.endTimeString ?? endTimeDisplay)")
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .padding(CalendoDesign.cardPadding)
        .calendoGlass(in: RoundedRectangle(cornerRadius: CalendoDesign.cornerRadius))
        .padding(.horizontal, CalendoDesign.screenPadding)
    }

    // MARK: - Error Card
    private var errorCard: some View {
        VStack(spacing: 8) {
            Text(errorMessage ?? "Άγνωστο σφάλμα")
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(CalendoDesign.cardPadding)
        .calendoGlass(in: RoundedRectangle(cornerRadius: CalendoDesign.cornerRadius))
        .padding(.horizontal, CalendoDesign.screenPadding)
    }

    // MARK: - Action Button
    @ViewBuilder
    private var actionButton: some View {
        VStack(spacing: 12) {
            Button {
                HapticManager.impact(.medium)
                appointmentData.reset()
                navigationPath = NavigationPath()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: state == .success ? "house.fill" : "arrow.counterclockwise")
                    Text(state == .success ? "Αρχική" : "Δοκιμάστε ξανά")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(CalendoDesign.purpleGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if state == .success {
                Button {
                    HapticManager.impact(.medium)
                    appointmentData.reset()
                    navigationPath = NavigationPath()
                    // Small delay then navigate to recording
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        navigationPath.append(AppScreen.recording)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                        Text("Νέο Ραντεβού")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.calendoPurple)
                }
            }
        }
    }

    // MARK: - Computed
    private var endTimeDisplay: String {
        if let end = appointmentData.endDate {
            return end.greekTimeString
        }
        return "?"
    }

    // MARK: - Create Event
    private func createEvent() async {
        state = .processing

        guard let startDate = appointmentData.startDate else {
            errorMessage = "Δεν βρέθηκε ημερομηνία/ώρα έναρξης"
            state = .error
            HapticManager.error()
            return
        }

        let endDate = appointmentData.endDate ?? startDate.addingTimeInterval(30 * 60)

        do {
            let token = try await authService.getCalendarAccessToken()

            let link = try await GoogleCalendarService.shared.createEvent(
                accessToken: token,
                title: appointmentData.eventTitle,
                startDate: startDate,
                endDate: endDate
            )

            eventLink = link
            state = .success
            HapticManager.success()
        } catch {
            errorMessage = error.localizedDescription
            state = .error
            HapticManager.error()
        }
    }
}
