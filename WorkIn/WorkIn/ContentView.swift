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
        TabView(selection: $selectedTab) {
            WorkoutView()
                .environmentObject(workoutStore)
                .environmentObject(themeManager)
                .environmentObject(profileStore)
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workouts")
                }
                .tag(0)

            NutritionView()
                .environmentObject(nutritionStore)
                .environmentObject(themeManager)
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

            AIAssistantView()
                .environmentObject(profileStore)
                .environmentObject(workoutStore)
                .environmentObject(nutritionStore)
                .environmentObject(templateStore)
                .environmentObject(themeManager)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("AI")
                }
                .tag(4)

            ProfileView()
                .environmentObject(themeManager)
                .environmentObject(authManager)
                .environmentObject(nutritionStore)
                .environmentObject(profileStore)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(5)
        }
        .accentColor(themeManager.accentColor)
        .background(themeManager.backgroundColor)
        .task {
            await workoutStore.loadWorkouts()
            nutritionStore.startFirebaseListeners()
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