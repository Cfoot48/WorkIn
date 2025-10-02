import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var profileStore = UserProfileStore()
    @State private var isSignUp = false

    var body: some View {
        if authManager.isAuthenticated {
            if !profileStore.hasCompletedOnboarding {
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

                    Spacer()
                }
                .padding()
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
                    ProgressView()
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
                    ProgressView()
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

#Preview {
    AuthenticationView()
        .environmentObject(ThemeManager())
        .environmentObject(AuthenticationManager())
        .environmentObject(WorkoutStore())
        .environmentObject(NutritionStore())
}