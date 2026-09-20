import SwiftUI

struct OnboardingView: View {
    @Environment(GoogleAuthService.self) private var authService
    @State private var isSigningIn = false
    @State private var showError = false
    @State private var animateIn = false
    @State private var animateLogo = false

    var body: some View {
        ZStack {
            // Background
            CalendoDesign.backgroundGradient.ignoresSafeArea()

            // Floating medical icons (decorative)
            FloatingIconsBackground()

            VStack(spacing: 0) {
                Spacer()

                // Logo & App Name
                VStack(spacing: 16) {
                    // App Icon
                    Image("AppIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: .calendoPurple.opacity(0.4), radius: 20, y: 10)
                        .scaleEffect(animateLogo ? 1.0 : 0.5)
                        .opacity(animateLogo ? 1.0 : 0.0)

                    Text("Calendo")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(animateIn ? 1.0 : 0.0)
                        .offset(y: animateIn ? 0 : 20)
                }

                Spacer().frame(height: 24)

                // Welcome Text
                VStack(spacing: 12) {
                    Text("Καλώς ήρθατε!")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("Το Calendo σας βοηθά να καταχωρείτε\nραντεβού ασθενών με τη φωνή σας.")
                        .font(.body)
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .opacity(animateIn ? 1.0 : 0.0)
                .offset(y: animateIn ? 0 : 30)

                Spacer().frame(height: 16)

                // Feature List
                VStack(spacing: 14) {
                    FeatureRow(icon: "mic.fill", color: .calendoCoral, text: "Εγγραφή φωνής στα Ελληνικά")
                    FeatureRow(icon: "brain.head.profile.fill", color: .calendoPurple, text: "AI αναγνώριση με Gemini")
                    FeatureRow(icon: "calendar.badge.plus", color: .calendoTeal, text: "Αυτόματη καταχώρηση στο Google Calendar")
                }
                .padding(.horizontal, 32)
                .opacity(animateIn ? 1.0 : 0.0)
                .offset(y: animateIn ? 0 : 40)

                Spacer()

                // Sign In Button
                VStack(spacing: 16) {
                    Button {
                        signIn()
                    } label: {
                        HStack(spacing: 12) {
                            if isSigningIn {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "g.circle.fill")
                                    .font(.title2)
                            }
                            Text(isSigningIn ? "Σύνδεση..." : "Σύνδεση με Google")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(CalendoDesign.purpleGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .calendoPurple.opacity(0.4), radius: 12, y: 6)
                    }
                    .disabled(isSigningIn)

                    Text("Απαιτείται πρόσβαση στο Google Calendar")
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                }
                .padding(.horizontal, CalendoDesign.screenPadding)
                .opacity(animateIn ? 1.0 : 0.0)
                .offset(y: animateIn ? 0 : 50)

                Spacer().frame(height: 40)
            }
        }
        .alert("Σφάλμα Σύνδεσης", isPresented: $showError) {
            Button("Εντάξει", role: .cancel) {}
        } message: {
            Text(authService.errorMessage ?? "Άγνωστο σφάλμα")
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animateLogo = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                animateIn = true
            }
        }
    }

    private func signIn() {
        isSigningIn = true
        HapticManager.impact(.medium)
        Task {
            do {
                try await authService.signIn()
                UserDefaults.standard.set(true, forKey: AppConstants.hasCompletedOnboarding)
                HapticManager.success()
            } catch {
                showError = true
                HapticManager.error()
            }
            isSigningIn = false
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.bold())
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.textPrimary)

            Spacer()
        }
    }
}

// MARK: - Floating Background Icons
struct FloatingIconsBackground: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                FloatingIcon(systemName: "stethoscope", size: 30, x: 50, y: 100, delay: 0)
                FloatingIcon(systemName: "heart.fill", size: 24, x: geometry.size.width - 70, y: 150, delay: 0.5)
                FloatingIcon(systemName: "calendar", size: 28, x: 80, y: geometry.size.height - 200, delay: 1.0)
                FloatingIcon(systemName: "waveform.path", size: 26, x: geometry.size.width - 60, y: geometry.size.height - 280, delay: 1.5)
            }
        }
        .opacity(0.08)
        .allowsHitTesting(false)
    }
}

struct FloatingIcon: View {
    let systemName: String
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    let delay: Double
    @State private var floating = false

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size))
            .foregroundStyle(.white)
            .position(x: x, y: y)
            .offset(y: floating ? -15 : 15)
            .animation(
                .easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(delay),
                value: floating
            )
            .onAppear { floating = true }
    }
}
