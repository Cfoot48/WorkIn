import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NSLog("🔥 Firebase: Configuring Firebase...")
        print("🔥 Firebase: Configuring Firebase...")
        FirebaseApp.configure()
        NSLog("🔥 Firebase: Configuration complete!")
        print("🔥 Firebase: Configuration complete!")

        // Verify Firebase app is configured
        if let app = FirebaseApp.app() {
            NSLog("🔥 Firebase: Default app configured successfully")
            NSLog("🔥 Firebase: App name: \(app.name)")
            print("🔥 Firebase: Default app configured successfully")
            print("🔥 Firebase: App name: \(app.name)")
        } else {
            NSLog("🔥 Firebase: ERROR - Default app not configured!")
            print("🔥 Firebase: ERROR - Default app not configured!")
        }

        return true
    }
}

@main
struct WorkInApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var workoutStore = WorkoutStore()
    @StateObject private var nutritionStore = NutritionStore()

    var body: some Scene {
        WindowGroup {
            AuthenticationView()
                .environmentObject(themeManager)
                .environmentObject(authManager)
                .environmentObject(workoutStore)
                .environmentObject(nutritionStore)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}