import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var templateStore: TemplateStore

    var body: some View {
        VStack(spacing: 0) {
            // Custom top bar with safe area
            VStack(spacing: 0) {
                // Content bar
                HStack {
                    Text("WORKIN")
                        .font(.system(size: 22, weight: .heavy, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan, Color(red: 0.3, green: 0.5, blue: 1.0)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.leading, 20)

                    Spacer()

                    HStack(spacing: 10) {
                        Image(systemName: "dumbbell.fill")
                            .foregroundColor(.cyan)
                        Image(systemName: "bolt.fill")
                            .foregroundColor(Color(red: 0.3, green: 0.5, blue: 1.0))
                    }
                    .font(.system(size: 16))
                    .padding(.trailing, 20)
                }
                .frame(height: 50)
                .background(
                    ZStack {
                        themeManager.backgroundColor

                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.cyan.opacity(0.1),
                                Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                )
            }
            .background(
                ZStack {
                    themeManager.backgroundColor

                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.cyan.opacity(0.1),
                            Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .ignoresSafeArea(edges: .top)
            )
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

            TabView(selection: $selectedTab) {
                WorkoutView()
                    .environmentObject(workoutStore)
                    .environmentObject(themeManager)
                    .environmentObject(profileStore)
                    .environmentObject(templateStore)
                    .tabItem {
                        Image(systemName: "dumbbell.fill")
                        Text("Workouts")
                    }
                    .tag(0)

                NutritionView()
                    .environmentObject(nutritionStore)
                    .environmentObject(themeManager)
                    .environmentObject(templateStore)
                    .environmentObject(profileStore)
                    .tabItem {
                        Image(systemName: "fork.knife")
                        Text("Nutrition")
                    }
                    .tag(1)

                ProgressView()
                    .environmentObject(workoutStore)
                    .environmentObject(nutritionStore)
                    .environmentObject(themeManager)
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Progress")
                    }
                    .tag(2)

                ChatView()
                    .environmentObject(chatManager)
                    .environmentObject(authManager)
                    .environmentObject(profileStore)
                    .environmentObject(themeManager)
                    .environmentObject(workoutStore)
                    .tabItem {
                        Image(systemName: "message.fill")
                        Text("Chat")
                    }
                    .tag(3)

                ProfileView()
                    .environmentObject(themeManager)
                    .environmentObject(authManager)
                    .environmentObject(nutritionStore)
                    .environmentObject(profileStore)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(4)
            }
            .accentColor(themeManager.accentColor)
            .background(themeManager.backgroundColor)
            .task {
                await workoutStore.loadWorkouts()
                nutritionStore.startFirebaseListeners()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutStore())
        .environmentObject(NutritionStore())
        .environmentObject(ThemeManager())
        .environmentObject(AuthenticationManager())
}