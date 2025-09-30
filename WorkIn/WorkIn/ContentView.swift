import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var workoutStore = WorkoutStore()

    var body: some View {
        TabView(selection: $selectedTab) {
            WorkoutView()
                .environmentObject(workoutStore)
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workouts")
                }
                .tag(0)

            NutritionView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Nutrition")
                }
                .tag(1)

            ProgressView()
                .environmentObject(workoutStore)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Progress")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .task {
            await workoutStore.loadWorkouts()
        }
    }
}

#Preview {
    ContentView()
}