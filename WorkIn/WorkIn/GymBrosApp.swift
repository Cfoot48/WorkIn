import SwiftUI
import Firebase

@main
struct GymBrosApp: App {
    @StateObject private var firebaseManager = FirebaseManager.shared

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if firebaseManager.isUserAuthenticated {
                    ContentView()
                        .environmentObject(firebaseManager)
                } else {
                    AuthenticationView()
                        .environmentObject(firebaseManager)
                }
            }
        }
    }
}