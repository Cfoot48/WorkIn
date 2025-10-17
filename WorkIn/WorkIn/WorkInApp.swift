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

        // Load saved workout templates
        WorkoutTemplateDatabase.loadTemplates()
        print("📋 Loaded \(WorkoutTemplateDatabase.templates.count) workout templates")

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
    @StateObject private var profileStore = UserProfileStore()
    @StateObject private var chatManager = ChatManager()
    @StateObject private var templateStore = TemplateStore()
    @State private var showSplash = true
    @State private var isAppReady = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Always render black background first
                Color.black.ignoresSafeArea()

                if !showSplash && isAppReady {
                    AuthenticationView()
                        .environmentObject(themeManager)
                        .environmentObject(authManager)
                        .environmentObject(workoutStore)
                        .environmentObject(nutritionStore)
                        .environmentObject(profileStore)
                        .environmentObject(chatManager)
                        .environmentObject(templateStore)
                        .preferredColorScheme(themeManager.colorScheme)
                        .transition(.opacity)
                }

                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(999)
                }
            }
            .task {
                // Connect profileStore to authManager for synchronous loading state updates
                authManager.profileStore = profileStore

                // Set up auth state change callbacks
                setupAuthCallbacks()

                // Initialize data stores if user is already authenticated
                if authManager.isAuthenticated {
                    // Set loading state BEFORE any UI can render
                    profileStore.isLoadingProfile = true
                    workoutStore.initializeForUser()
                    nutritionStore.initializeForUser()
                    await profileStore.loadProfile()
                }

                isAppReady = true

                // Keep splash screen visible for minimum duration
                try? await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds

                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }

    private func setupAuthCallbacks() {
        // Handle user sign in
        authManager.onUserSignedIn = { [weak workoutStore, weak nutritionStore, weak profileStore] in
            print("🔄 App: User signed in, initializing data stores...")

            // Loading state is already set in AuthenticationManager before this callback fires

            workoutStore?.initializeForUser()
            nutritionStore?.initializeForUser()

            Task {
                await profileStore?.loadProfile()
            }
        }

        // Handle user sign out
        authManager.onUserSignedOut = { [weak workoutStore, weak nutritionStore, weak profileStore] in
            print("🔄 App: User signed out, clearing data stores...")
            workoutStore?.clearDataAndListeners()
            nutritionStore?.clearDataAndListeners()
            profileStore?.resetProfile()
        }
    }
}

// MARK: - Splash Screen
struct SplashScreenView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var letterSpacing: CGFloat = -20
    @State private var blurRadius: CGFloat = 15
    @State private var iconScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            // White background
            Color.white.ignoresSafeArea()

            // Animated gradient background with orange to white
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.50, blue: 0.35).opacity(0.6), // Light coral
                    Color(red: 1.0, green: 0.42, blue: 0.24).opacity(0.5), // Primary orange
                    Color(red: 0.90, green: 0.35, blue: 0.15).opacity(0.3), // Dark orange
                    Color.white.opacity(0.8),
                    Color.white
                ]),
                center: .center,
                startRadius: 80,
                endRadius: 500
            )
            .ignoresSafeArea()
            .scaleEffect(scale)
            .blur(radius: 25)

            // Animated background circles with coral to orange gradient glow
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.50, blue: 0.35).opacity(0.3), // Light coral center
                                Color(red: 1.0, green: 0.42, blue: 0.24).opacity(0.25), // Primary orange
                                Color(red: 0.90, green: 0.35, blue: 0.15).opacity(0.15), // Dark orange
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 250
                        )
                    )
                    .frame(width: 200 + CGFloat(index * 100), height: 200 + CGFloat(index * 100))
                    .blur(radius: 60)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation * Double(index + 1) * 0.3))
                    .offset(
                        x: CGFloat(index - 1) * 50,
                        y: CGFloat(index - 1) * -30
                    )
            }

            VStack(spacing: 40) {
                // Dumbbell icon - matching dark color
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(Color(red: 0.65, green: 0.20, blue: 0.08)) // Same dark orange/brown as text
                    .shadow(color: Color(red: 0.90, green: 0.35, blue: 0.15).opacity(0.4), radius: 8, x: 0, y: 2)
                    .blur(radius: blurRadius * 0.3)
                    .scaleEffect(iconScale)
                    .opacity(opacity)

                // Main WORKIN text - dark and bold
                Text("WORKIN")
                    .font(.system(size: 70, weight: .heavy, design: .default))
                    .kerning(letterSpacing)
                    .foregroundColor(Color(red: 0.65, green: 0.20, blue: 0.08)) // Much darker orange/brown for visibility
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.5), radius: 20, x: 0, y: 0)
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.35), radius: 35, x: 0, y: 0)
                    .blur(radius: blurRadius)
                    .scaleEffect(scale)
                    .opacity(opacity)

                // Subtitle
                Text("TRACK YOUR GAINS")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundColor(Color(red: 0.70, green: 0.25, blue: 0.10)) // Much darker orange/brown
                    .opacity(opacity)
            }
        }
        .onAppear {
            // Animate background rotation
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            // Animate circles pulse
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                scale = 1.3
            }

            // Animate icon appearance
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                iconScale = 1.0
                opacity = 1.0
            }

            // Animate text appearance
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                scale = 1.0
            }

            withAnimation(.easeOut(duration: 1.0).delay(0.6)) {
                letterSpacing = 8
                blurRadius = 0
            }
        }
    }
}