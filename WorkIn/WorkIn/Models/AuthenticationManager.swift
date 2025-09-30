import Foundation
import FirebaseAuth
import Combine

class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        user = Auth.auth().currentUser
        isAuthenticated = user != nil

        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
        }
    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        user = result.user
        isAuthenticated = true
    }

    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        user = result.user
        isAuthenticated = true
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