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

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Always render black background first
                Color.black.ignoresSafeArea()

                if !showSplash {
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
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
    @State private var blurRadius: CGFloat = 20

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.cyan.opacity(0.4),
                    Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.5),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(rotation))

            // Animated background circles
            ForEach(0..<5) { index in
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 150 + CGFloat(index * 80), height: 150 + CGFloat(index * 80))
                    .blur(radius: 40)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation * Double(index + 1) * 0.5))
            }

            VStack(spacing: 30) {
                // Main WORKIN text
                Text("WORKIN")
                    .font(.system(size: 80, weight: .heavy, design: .default))
                    .kerning(letterSpacing)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .cyan, Color(red: 0.3, green: 0.5, blue: 1.0), .white]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .cyan, radius: 20, x: 0, y: 0)
                    .shadow(color: Color(red: 0.3, green: 0.5, blue: 1.0), radius: 30, x: 0, y: 0)
                    .blur(radius: blurRadius)
                    .scaleEffect(scale)
                    .opacity(opacity)

                // Animated dumbbells icon
                HStack(spacing: 8) {
                    Image(systemName: "dumbbell.fill")
                    Image(systemName: "figure.run")
                    Image(systemName: "flame.fill")
                }
                .font(.system(size: 30))
                .foregroundColor(.white)
                .opacity(opacity)
                .scaleEffect(scale)
            }
        }
        .onAppear {
            // Animate background rotation
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            // Animate circles
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.2
            }

            // Animate text appearance
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 1.0
                scale = 1.0
            }

            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                letterSpacing = 5
                blurRadius = 0
            }
        }
    }
}