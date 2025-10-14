import Foundation
import FirebaseAuth
import FirebaseCore
import Combine
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false

    private var cancellables = Set<AnyCancellable>()

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
            self?.user = user
            self?.isAuthenticated = user != nil
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