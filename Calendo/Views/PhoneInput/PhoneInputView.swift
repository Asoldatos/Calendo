import SwiftUI

/// Phone input screen — "Εισάγετε το τηλέφωνο του ασθενούς"
/// Has a skip button for when the patient doesn't want to give their number.
struct PhoneInputView: View {
    @Binding var navigationPath: NavigationPath
    var appointmentData: AppointmentData
    @State private var phoneNumber = ""
    @FocusState private var isPhoneFocused: Bool

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
                            .fill(Color.calendoTeal.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "phone.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.calendoTeal)
                    }

                    // Title
                    VStack(spacing: 8) {
                        Text("Τηλέφωνο Ασθενούς")
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text("Εισάγετε το τηλέφωνο του ασθενούς")
                            .font(.subheadline)
                            .foregroundStyle(.textSecondary)
                    }

                    // Appointment Summary
                    appointmentSummaryCard

                    // Phone Input
                    HStack(spacing: 12) {
                        // Country code
                        Text("+30")
                            .font(.title3.bold())
                            .foregroundStyle(.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 16)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))

                        // Phone number field
                        TextField("69XXXXXXXX", text: $phoneNumber)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .keyboardType(.phonePad)
                            .focused($isPhoneFocused)
                            .padding(16)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, CalendoDesign.screenPadding)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    // Done button
                    Button {
                        HapticManager.impact(.heavy)
                        appointmentData.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
                        navigationPath.append(AppScreen.processing)
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

                    // Skip button
                    Button {
                        HapticManager.lightTap()
                        appointmentData.phoneNumber = nil
                        navigationPath.append(AppScreen.processing)
                    } label: {
                        Text("Παράλειψη")
                            .font(.subheadline.bold())
                            .foregroundStyle(.textSecondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, CalendoDesign.screenPadding)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            isPhoneFocused = true
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

            Text("Τηλέφωνο")
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
    }

    // MARK: - Appointment Summary
    private var appointmentSummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            if appointmentData.hasName {
                HStack(spacing: 10) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.calendoPurple)
                    Text(appointmentData.patientName ?? "")
                        .foregroundStyle(.white)
                        .font(.subheadline.bold())
                }
            }

            HStack(spacing: 20) {
                if appointmentData.hasDate {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .foregroundStyle(.calendoTeal)
                        Text(appointmentData.dateString ?? "")
                            .foregroundStyle(.textSecondary)
                            .font(.caption)
                    }
                }
                if appointmentData.hasTime {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundStyle(.calendoGold)
                        Text(appointmentData.startTimeString ?? "")
                            .foregroundStyle(.textSecondary)
                            .font(.caption)
                    }
                }
                if appointmentData.hasDuration {
                    HStack(spacing: 6) {
                        Image(systemName: "hourglass")
                            .foregroundStyle(.calendoCoral)
                        Text(durationDisplay)
                            .foregroundStyle(.textSecondary)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, CalendoDesign.screenPadding)
    }

    private var durationDisplay: String {
        if let end = appointmentData.endTimeString, !end.isEmpty {
            return "έως \(end)"
        }
        if let mins = appointmentData.durationMinutes {
            if mins >= 60 {
                let hours = mins / 60
                let remainder = mins % 60
                if remainder == 0 { return "\(hours) ώρ." }
                return "\(hours) ώρ. \(remainder) λ."
            }
            return "\(mins) λεπτά"
        }
        return ""
    }
}
