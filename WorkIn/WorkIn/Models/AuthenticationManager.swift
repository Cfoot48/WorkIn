import Foundation
import FirebaseAuth
import FirebaseCore
import Combine
import SwiftUI
import AuthenticationServices
import CryptoKit
import GoogleSignIn

class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false

    private var cancellables = Set<AnyCancellable>()

    // Callbacks for data store management
    var onUserSignedIn: (() -> Void)?
    var onUserSignedOut: (() -> Void)?

    // Weak reference to profile store to set loading state synchronously
    weak var profileStore: UserProfileStore?

    init() {
        print("🔥 Firebase Auth: Initializing AuthenticationManager")

        // Check if Firebase is configured
        if FirebaseApp.app() == nil {
            print("🔥 Firebase Auth Error: Firebase not configured!")
        } else {
            print("🔥 Firebase Auth: Firebase is configured")
        }

        user = Auth.auth().currentUser
        isAuthenticated = user != nil

        print("🔥 Firebase Auth: Current user: \(user?.email ?? "None")")
        print("🔥 Firebase Auth: Is authenticated: \(isAuthenticated)")

        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("🔥 Firebase Auth: State changed - User: \(user?.email ?? "None")")
            let wasAuthenticated = self?.isAuthenticated ?? false

            // If user is signing in, set loading state BEFORE updating isAuthenticated
            if user != nil && !wasAuthenticated {
                print("🔥 Firebase Auth: User signing in, setting loading state")
                self?.profileStore?.isLoadingProfile = true
            }

            self?.user = user
            self?.isAuthenticated = user != nil

            // Trigger callbacks when auth state changes
            if user != nil && !wasAuthenticated {
                // User just signed in
                print("🔥 Firebase Auth: User signed in, triggering initialization")
                self?.onUserSignedIn?()
            } else if user == nil && wasAuthenticated {
                // User just signed out
                print("🔥 Firebase Auth: User signed out, triggering cleanup")
                self?.onUserSignedOut?()
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        print("🔥 Firebase Auth: Attempting sign in for email: \(email)")
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("🔥 Firebase Auth: Sign in successful for user: \(result.user.email ?? "unknown")")
            user = result.user
            isAuthenticated = true
        } catch {
            print("🔥 Firebase Auth: Sign in failed with error: \(error)")
            throw error
        }
    }

    func signUp(email: String, password: String) async throws {
        print("🔥 Firebase Auth: Attempting sign up for email: \(email)")
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("🔥 Firebase Auth: Sign up successful for user: \(result.user.email ?? "unknown")")
            user = result.user
            isAuthenticated = true
        } catch {
            print("🔥 Firebase Auth: Sign up failed with error: \(error)")
            throw error
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
        user = nil
        isAuthenticated = false
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        print("🔥 Firebase Auth: Deleting user account: \(user.email ?? "unknown")")

        // Try to delete the account
        do {
            try await user.delete()
            print("🔥 Firebase Auth: User account deleted successfully")

            await MainActor.run {
                self.user = nil
                self.isAuthenticated = false
            }
        } catch let error as NSError {
            // Check if this is a "requires recent login" error
            if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                print("🔥 Firebase Auth: Account deletion requires recent authentication")
                throw AccountDeletionError.requiresRecentLogin
            } else {
                print("🔥 Firebase Auth: Account deletion failed: \(error.localizedDescription)")
                throw error
            }
        }
    }

    func reauthenticateForDeletion(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        print("🔥 Firebase Auth: Re-authenticating user for account deletion...")

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)

        print("🔥 Firebase Auth: Re-authentication successful")
    }

    func reauthenticateWithGoogleForDeletion() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase client ID"])
        }

        print("🔥 Firebase Auth: Re-authenticating with Google for account deletion...")

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = await windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller"])
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing ID token"])
        }

        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

        try await user.reauthenticate(with: credential)

        print("🔥 Firebase Auth: Re-authentication with Google successful")
    }

    func getUserProviders() -> [String] {
        return Auth.auth().currentUser?.providerData.map { $0.providerID } ?? []
    }

    // MARK: - Apple Sign In

    private var currentNonce: String?

    func signInWithApple() async throws {
        let nonce = randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        // This will trigger the Apple Sign In sheet
        // The result will be handled by the coordinator
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task { @MainActor in
                let coordinator = AppleSignInCoordinator(continuation: continuation, authManager: self)
                authorizationController.delegate = coordinator
                authorizationController.presentationContextProvider = coordinator
                authorizationController.performRequests()
            }
        }
    }

    func handleAppleSignInCompletion(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID credential"])
        }

        guard let nonce = currentNonce else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid nonce"])
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string"])
        }

        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)

        let result = try await Auth.auth().signIn(with: credential)
        print("🔥 Firebase Auth: Apple Sign In successful for user: \(result.user.email ?? "unknown")")
        user = result.user
        isAuthenticated = true
    }

    // MARK: - Google Sign In

    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase client ID"])
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = await windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller"])
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "com.workin.auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing ID token"])
        }

        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

        let authResult = try await Auth.auth().signIn(with: credential)
        print("🔥 Firebase Auth: Google Sign In successful for user: \(authResult.user.email ?? "unknown")")
        user = authResult.user
        isAuthenticated = true
    }

    // MARK: - Helper Functions

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// MARK: - Apple Sign In Coordinator

class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let continuation: CheckedContinuation<Void, Error>
    private let authManager: AuthenticationManager

    init(continuation: CheckedContinuation<Void, Error>, authManager: AuthenticationManager) {
        self.continuation = continuation
        self.authManager = authManager
    }

    @MainActor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available")
        }
        return window
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            do {
                try await authManager.handleAppleSignInCompletion(authorization: authorization)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
}

class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil
    @Published var isDarkMode: Bool = false {
        didSet {
            updateColorScheme()
            savePreference()
        }
    }

    private let userDefaults = UserDefaults.standard
    private let darkModeKey = "isDarkMode"

    init() {
        loadPreference()
        updateColorScheme()
    }

    private func updateColorScheme() {
        colorScheme = isDarkMode ? .dark : .light
    }

    private func savePreference() {
        userDefaults.set(isDarkMode, forKey: darkModeKey)
    }

    private func loadPreference() {
        isDarkMode = userDefaults.bool(forKey: darkModeKey)
    }

    func toggleDarkMode() {
        isDarkMode.toggle()
    }

    // MARK: - Design System Colors
    var backgroundColor: Color {
        DesignSystem.Colors.background(for: colorScheme ?? .light)
    }

    var secondaryBackgroundColor: Color {
        isDarkMode ? Color(red: 0.17, green: 0.17, blue: 0.17) : Color.gray.opacity(0.1)
    }

    var cardBackgroundColor: Color {
        DesignSystem.Colors.card(for: colorScheme ?? .light)
    }

    var primaryTextColor: Color {
        DesignSystem.Colors.textPrimary(for: colorScheme ?? .light)
    }

    var secondaryTextColor: Color {
        DesignSystem.Colors.textSecondary(for: colorScheme ?? .light)
    }

    var accentColor: Color {
        DesignSystem.Colors.primary
    }
}

// MARK: - Account Deletion Error

enum AccountDeletionError: LocalizedError {
    case requiresRecentLogin

    var errorDescription: String? {
        switch self {
        case .requiresRecentLogin:
            return "For security, you must re-authenticate before deleting your account."
        }
    }
}