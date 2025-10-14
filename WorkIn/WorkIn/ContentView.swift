import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
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
                    .environmentObject(templateStore)
                    .tabItem {
                        Label {
                            Text("Workouts")
                        } icon: {
                            Image(systemName: selectedTab == 0 ? "dumbbell.fill" : "dumbbell")
                        }
                    }
                    .tag(0)

                NutritionView()
                    .environmentObject(nutritionStore)
                    .environmentObject(themeManager)
                    .environmentObject(templateStore)
                    .environmentObject(profileStore)
                    .tabItem {
                        Label {
                            Text("Nutrition")
                        } icon: {
                            Image(systemName: selectedTab == 1 ? "fork.knife.circle.fill" : "fork.knife")
                        }
                    }
                    .tag(1)

                ProgressView(mainTabSelection: $selectedTab)
                    .environmentObject(workoutStore)
                    .environmentObject(nutritionStore)
                    .environmentObject(themeManager)
                    .tabItem {
                        Label {
                            Text("Progress")
                        } icon: {
                            Image(systemName: selectedTab == 2 ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.line.uptrend.xyaxis")
                        }
                    }
                    .tag(2)

                ChatView()
                    .environmentObject(chatManager)
                    .environmentObject(authManager)
                    .environmentObject(profileStore)
                    .environmentObject(themeManager)
                    .environmentObject(workoutStore)
                    .tabItem {
                        Label {
                            Text("Chat")
                        } icon: {
                            Image(systemName: selectedTab == 3 ? "bubble.left.and.bubble.right.fill" : "bubble.left.and.bubble.right")
                        }
                    }
                    .tag(3)

                ProfileView()
                    .environmentObject(themeManager)
                    .environmentObject(authManager)
                    .environmentObject(nutritionStore)
                    .environmentObject(profileStore)
                    .tabItem {
                        Label {
                            Text("Profile")
                        } icon: {
                            Image(systemName: selectedTab == 4 ? "person.circle.fill" : "person.circle")
                        }
                    }
                    .tag(4)
            }
            .tint(DesignSystem.Colors.primary)
            .background(DesignSystem.Colors.background(for: colorScheme))
            .gesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                    .onEnded { value in
                        handleSwipe(value: value)
                    }
            )
            .onAppear {
                // Ensure we start on the Workouts tab
                selectedTab = 0
            }
    }

    private func handleSwipe(value: DragGesture.Value) {
        let horizontalAmount = value.translation.width
        let verticalAmount = value.translation.height

        // Only respond to horizontal swipes (ignore if too vertical)
        if abs(horizontalAmount) > abs(verticalAmount) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                if horizontalAmount < 0 {
                    // Swipe left - go to next tab
                    if selectedTab < 4 {
                        selectedTab += 1
                    }
                } else {
                    // Swipe right - go to previous tab
                    if selectedTab > 0 {
                        selectedTab -= 1
                    }
                }
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