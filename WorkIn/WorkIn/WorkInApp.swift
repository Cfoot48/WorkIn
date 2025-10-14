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
                // Load everything while splash screen is showing
                await workoutStore.loadWorkouts()
                nutritionStore.startFirebaseListeners()

                if authManager.isAuthenticated {
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
            // Deep black background
            Color.black.ignoresSafeArea()

            // Animated gradient background with coral to orange
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.50, blue: 0.35).opacity(0.4), // Light coral
                    Color(red: 1.0, green: 0.42, blue: 0.24).opacity(0.3), // Primary orange
                    Color(red: 0.90, green: 0.35, blue: 0.15).opacity(0.2), // Dark orange
                    Color.black,
                    Color.black
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
                                Color(red: 1.0, green: 0.50, blue: 0.35).opacity(0.2), // Light coral center
                                Color(red: 1.0, green: 0.42, blue: 0.24).opacity(0.15), // Primary orange
                                Color(red: 0.90, green: 0.35, blue: 0.15).opacity(0.08), // Dark orange
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
                // Dumbbell icon with glow
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.42, blue: 0.24), // Primary orange
                                Color(red: 1.0, green: 0.50, blue: 0.35)  // Light orange
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.24).opacity(0.8), radius: 20, x: 0, y: 0)
                    .shadow(color: Color(red: 1.0, green: 0.50, blue: 0.35).opacity(0.6), radius: 40, x: 0, y: 0)
                    .blur(radius: blurRadius * 0.3)
                    .scaleEffect(iconScale)
                    .opacity(opacity)

                // Main WORKIN text with gradient
                Text("WORKIN")
                    .font(.system(size: 70, weight: .heavy, design: .default))
                    .kerning(letterSpacing)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.42, blue: 0.24), // Primary orange
                                Color(red: 1.0, green: 0.50, blue: 0.35), // Light orange
                                Color(red: 1.0, green: 0.42, blue: 0.24)  // Primary orange
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.24).opacity(0.8), radius: 30, x: 0, y: 0)
                    .shadow(color: Color(red: 1.0, green: 0.50, blue: 0.35).opacity(0.6), radius: 50, x: 0, y: 0)
                    .blur(radius: blurRadius)
                    .scaleEffect(scale)
                    .opacity(opacity)

                // Subtitle
                Text("TRACK YOUR GAINS")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.7))
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