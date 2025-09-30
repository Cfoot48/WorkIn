import SwiftUI
import FirebaseCore

@main
struct WorkInApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
    }
}