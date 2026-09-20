import SwiftUI

struct ContentView: View {
    @Environment(GoogleAuthService.self) private var authService
    @Environment(QuickActionManager.self) private var quickActionManager
    @State private var navigationPath = NavigationPath()
    @State private var appointmentData = AppointmentData()
    @State private var showRecordingFromShortcut = false

    var body: some View {
        Group {
            if !authService.isSignedIn {
                OnboardingView()
            } else {
                NavigationStack(path: $navigationPath) {
                    HomeView(navigationPath: $navigationPath, appointmentData: appointmentData)
                        .navigationDestination(for: AppScreen.self) { screen in
                            switch screen {
                            case .recording:
                                RecordingView(
                                    navigationPath: $navigationPath,
                                    appointmentData: appointmentData
                                )
                            case .durationInput:
                                DurationInputView(
                                    navigationPath: $navigationPath,
                                    appointmentData: appointmentData
                                )
                            case .phoneInput:
                                PhoneInputView(
                                    navigationPath: $navigationPath,
                                    appointmentData: appointmentData
                                )
                            case .processing:
                                ProcessingView(
                                    navigationPath: $navigationPath,
                                    appointmentData: appointmentData
                                )
                            case .success:
                                EmptyView()
                            }
                        }
                }
            }
        }
        .onChange(of: quickActionManager.pendingAction) { _, newAction in
            if newAction == AppConstants.recordShortcutType {
                // Launch directly into recording
                if authService.isSignedIn {
                    appointmentData.reset()
                    navigationPath = NavigationPath()
                    navigationPath.append(AppScreen.recording)
                }
                quickActionManager.pendingAction = nil
            }
        }
        .animation(.smooth(duration: 0.4), value: authService.isSignedIn)
        .task {
            await authService.restoreSession()
        }
    }
}
