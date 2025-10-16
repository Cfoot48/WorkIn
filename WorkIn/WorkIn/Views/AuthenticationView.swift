import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var templateStore: TemplateStore
    @State private var isSignUp = false

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                if profileStore.isLoadingProfile {
                    // Show loading indicator while checking onboarding status
                    VStack(spacing: 20) {
                        SwiftUI.ProgressView()
                            .scaleEffect(1.5)
                            .tint(DesignSystem.Colors.primary)
                        Text("Loading profile...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !profileStore.hasCompletedOnboarding {
                    OnboardingView(
                        profileStore: profileStore,
                        isCompleted: $profileStore.hasCompletedOnboarding
                    )
                } else {
                    ContentView()
                        .environmentObject(authManager)
                        .environmentObject(workoutStore)
                        .environmentObject(nutritionStore)
                        .environmentObject(themeManager)
                        .environmentObject(profileStore)
                        .environmentObject(chatManager)
                        .environmentObject(templateStore)
                        .transition(.opacity)
                }
            } else {
                NavigationView {
                    VStack(spacing: 20) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)

                        Text("WorkIn")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Track your fitness journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        if isSignUp {
                            SignUpView(authManager: authManager)
                        } else {
                            SignInView(authManager: authManager)
                        }

                        Button(action: { isSignUp.toggle() }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }

                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                            Text("or")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.vertical, 8)

                        // Social Sign In Buttons
                        SocialSignInButtons(authManager: authManager)

                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .onChange(of: authManager.isAuthenticated) { newValue in
            if !newValue {
                // User signed out - reset profile
                profileStore.resetProfile()
            }
        }
    }
}

struct SignInView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: signIn) {
                if isLoading {
                    SwiftUI.ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(email.isEmpty || password.isEmpty || isLoading)
        }
    }

    private func signIn() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await authManager.signIn(email: email, password: password)
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("🔥 Firebase Sign In Error: \(error)")
                    print("🔥 Error Description: \(error.localizedDescription)")
                    if let nsError = error as NSError? {
                        print("🔥 Error Code: \(nsError.code)")
                        print("🔥 Error Domain: \(nsError.domain)")
                        print("🔥 User Info: \(nsError.userInfo)")
                    }
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct SignUpView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: signUp) {
                if isLoading {
                    SwiftUI.ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!isValidForm || isLoading)
        }
    }

    private var isValidForm: Bool {
        !email.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 6
    }

    private func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await authManager.signUp(email: email, password: password)
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("🔥 Firebase Sign Up Error: \(error)")
                    print("🔥 Error Description: \(error.localizedDescription)")
                    if let nsError = error as NSError? {
                        print("🔥 Error Code: \(nsError.code)")
                        print("🔥 Error Domain: \(nsError.domain)")
                        print("🔥 User Info: \(nsError.userInfo)")
                    }
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct SocialSignInButtons: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: 12) {
            // Google Sign In Button
            Button(action: signInWithGoogle) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 20))
                    Text("Continue with Google")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .disabled(isLoading)

            // Apple Sign In Button (commented out until Apple Developer account is configured)
            /*
            Button(action: signInWithApple) {
                HStack {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20))
                    Text("Continue with Apple")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(10)
            }
            .disabled(isLoading)
            */

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func signInWithApple() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await authManager.signInWithApple()
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                    print("🍎 Apple Sign In Error: \(error)")
                }
            }
        }
    }

    private func signInWithGoogle() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await authManager.signInWithGoogle()
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                    print("🔴 Google Sign In Error: \(error)")
                }
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(ThemeManager())
        .environmentObject(AuthenticationManager())
        .environmentObject(WorkoutStore())
        .environmentObject(NutritionStore())
}