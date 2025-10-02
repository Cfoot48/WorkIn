import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutView()
                .environmentObject(workoutStore)
                .environmentObject(themeManager)
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

            ProfileView()
                .environmentObject(themeManager)
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
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