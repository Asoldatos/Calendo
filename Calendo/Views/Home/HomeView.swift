import SwiftUI

struct HomeView: View {
    @Environment(GoogleAuthService.self) private var authService
    @Binding var navigationPath: NavigationPath
    var appointmentData: AppointmentData
    @State private var showSignOutAlert = false
    @State private var animateButton = false

    var body: some View {
        ZStack {
            CalendoDesign.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - Header
                    headerSection

                    // MARK: - New Appointment Button (Main CTA)
                    newAppointmentButton

                    // MARK: - Quick Info Cards
                    infoCardsSection

                    // MARK: - How It Works
                    howItWorksSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, CalendoDesign.screenPadding)
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
        .alert("Αποσύνδεση", isPresented: $showSignOutAlert) {
            Button("Ακύρωση", role: .cancel) {}
            Button("Αποσύνδεση", role: .destructive) {
                authService.signOut()
            }
        } message: {
            Text("Θέλετε να αποσυνδεθείτε από το Calendo;")
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().greekGreeting + ",")
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)

                Text(authService.userName)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button {
                showSignOutAlert = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(.textSecondary)
                    .frame(width: 44, height: 44)
                    .calendoGlass(in: Circle())
            }
        }
    }

    // MARK: - Main CTA
    private var newAppointmentButton: some View {
        Button {
            HapticManager.impact(.heavy)
            appointmentData.reset()
            navigationPath.append(AppScreen.recording)
        } label: {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(CalendoDesign.purpleGradient)
                        .frame(width: 80, height: 80)
                        .shadow(color: .calendoPurple.opacity(0.5), radius: 16, y: 8)

                    Image(systemName: "mic.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                        .scaleEffect(animateButton ? 1.1 : 1.0)
                }

                VStack(spacing: 6) {
                    Text("Νέο Ραντεβού")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    Text("Πατήστε για εγγραφή φωνής")
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .calendoGlass(in: RoundedRectangle(cornerRadius: CalendoDesign.cornerRadius))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateButton = true
            }
        }
    }

    // MARK: - Info Cards
    private var infoCardsSection: some View {
        HStack(spacing: 14) {
            InfoCard(
                icon: "calendar.badge.clock",
                title: "Σήμερα",
                value: Date().greekDateString,
                color: .calendoTeal
            )

            InfoCard(
                icon: "person.fill",
                title: "Λογαριασμός",
                value: authService.userEmail,
                color: .calendoPurple
            )
        }
    }

    // MARK: - How It Works
    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Πώς λειτουργεί")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                StepRow(number: 1, icon: "mic.fill", text: "Πατήστε \"Νέο Ραντεβού\" και μιλήστε")
                StepRow(number: 2, icon: "brain.head.profile.fill", text: "Το AI αναγνωρίζει ημερομηνία, ώρα, όνομα")
                StepRow(number: 3, icon: "phone.fill", text: "Εισάγετε τηλέφωνο (προαιρετικά)")
                StepRow(number: 4, icon: "checkmark.circle.fill", text: "Το ραντεβού καταχωρείται αυτόματα!")
            }
        }
        .padding(CalendoDesign.cardPadding)
        .calendoGlass(in: RoundedRectangle(cornerRadius: CalendoDesign.cornerRadius))
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.textSecondary)

            Text(value)
                .font(.caption2)
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .calendoGlass(in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Step Row
struct StepRow: View {
    let number: Int
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.calendoPurple.opacity(0.2))
                    .frame(width: 36, height: 36)

                Text("\(number)")
                    .font(.caption.bold())
                    .foregroundStyle(.calendoPurple)
            }

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)

            Spacer()
        }
    }
}
