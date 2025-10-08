import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var nutritionStore: NutritionStore
    @State private var showingSettings = false
    @State private var showingGoals = false

    var body: some View {
        NavigationView {
            if !profileStore.hasCompletedOnboarding {
                OnboardingView(
                    profileStore: profileStore,
                    isCompleted: $profileStore.hasCompletedOnboarding
                )
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        ProfileHeaderView(authManager: authManager)

                        QuickStatsView(profile: profileStore.profile)

                        ProfileMenuView(
                            authManager: authManager,
                            showingSettings: $showingSettings,
                            showingGoals: $showingGoals
                        )
                    }
                    .padding()
                }
                .background(themeManager.backgroundColor)
                .navigationTitle("Profile")
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $showingGoals) {
                    GoalsView(profileStore: profileStore, nutritionStore: nutritionStore)
                }
            }
        }
    }
}

struct ProfileHeaderView: View {
    @ObservedObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var profileStore: UserProfileStore
    @State private var showingEditName = false
    @State private var newName = ""

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(themeManager.accentColor)

            VStack(spacing: 4) {
                HStack {
                    Text(profileStore.profile.displayName.isEmpty ? (authManager.user?.email ?? "User") : profileStore.profile.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryTextColor)

                    if authManager.user?.email == "wkbf10@gmail.com" {
                        Text("(Developer)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    Button(action: {
                        newName = profileStore.profile.displayName
                        showingEditName = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(themeManager.accentColor)
                    }
                }

                Text("Fitness Enthusiast")
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
        .padding()
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
        .alert("Edit Display Name", isPresented: $showingEditName) {
            TextField("Enter your name", text: $newName)
            Button("Cancel", role: .cancel) {
                newName = ""
            }
            Button("Save") {
                saveNewName()
            }
        } message: {
            Text("This name will be shown in your profile and chat messages")
        }
    }

    private func saveNewName() {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            profileStore.profile.displayName = trimmedName
        }
        newName = ""
    }
}

struct QuickStatsView: View {
    let profile: UserProfile
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)
                .foregroundColor(themeManager.primaryTextColor)

            HStack(spacing: 16) {
                QuickStatCard(icon: "figure.walk", title: "Height", value: profile.heightFormatted)
                QuickStatCard(icon: "scalemass", title: "Weight", value: "\(Int(profile.currentWeight)) lbs")
                QuickStatCard(icon: "target", title: "Goal", value: profile.goalType.rawValue, color: profile.goalType.color)
            }
        }
        .padding()
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
    }
}

struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    var color: Color?
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color ?? themeManager.accentColor)

            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color ?? themeManager.primaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(8)
        .shadow(color: themeManager.isDarkMode ? .clear : .gray.opacity(0.3), radius: 1)
    }
}

struct ProfileMenuView: View {
    @ObservedObject var authManager: AuthenticationManager
    @Binding var showingSettings: Bool
    @Binding var showingGoals: Bool

    var body: some View {
        VStack(spacing: 12) {
            ProfileMenuItem(
                icon: "target",
                title: "Goals & Targets",
                action: { showingGoals = true }
            )

            ProfileMenuItem(
                icon: "chart.bar.fill",
                title: "Detailed Analytics",
                action: { }
            )

            ProfileMenuItem(
                icon: "heart.fill",
                title: "Health Data",
                action: { }
            )

            ProfileMenuItem(
                icon: "gear",
                title: "Settings",
                action: { showingSettings = true }
            )

            ProfileMenuItem(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Sign Out",
                action: {
                    do {
                        try authManager.signOut()
                    } catch {
                        print("Error signing out: \(error)")
                    }
                }
            )

            ProfileMenuItem(
                icon: "questionmark.circle",
                title: "Help & Support",
                action: { }
            )

            // DEBUG: Reset Onboarding
            ProfileMenuItem(
                icon: "arrow.counterclockwise",
                title: "Reset Onboarding (DEBUG)",
                action: {
                    UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                    UserDefaults.standard.removeObject(forKey: "userProfile")
                    print("🔄 Onboarding reset - restart app to see onboarding")
                }
            )
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 30)

                Text(title)
                    .font(.body)
                    .foregroundColor(themeManager.primaryTextColor)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .padding()
            .background(themeManager.secondaryBackgroundColor.opacity(0.5))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var notificationsEnabled = true

    var body: some View {
        NavigationView {
            Form {
                Section("Preferences") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    Toggle("Dark Mode", isOn: $themeManager.isDarkMode)
                }

                Section("Units") {
                    HStack {
                        Text("Weight Unit")
                        Spacer()
                        Text("lbs")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Distance Unit")
                        Spacer()
                        Text("miles")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Account") {
                    Button("Export Data") { }
                    Button("Privacy Policy") { }
                    Button("Terms of Service") { }
                }

                Section {
                    Button("Sign Out") { }
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct GoalsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profileStore: UserProfileStore
    @ObservedObject var nutritionStore: NutritionStore

    @State private var currentWeight: String
    @State private var goalWeight: String
    @State private var height: String
    @State private var dailyCalories: String
    @State private var dailyProtein: String
    @State private var weeklyWorkouts: String

    init(profileStore: UserProfileStore, nutritionStore: NutritionStore) {
        self.profileStore = profileStore
        self.nutritionStore = nutritionStore
        _currentWeight = State(initialValue: String(Int(profileStore.profile.currentWeight)))
        _goalWeight = State(initialValue: String(Int(profileStore.profile.goalWeight)))
        _height = State(initialValue: String(Int(profileStore.profile.height)))
        _dailyCalories = State(initialValue: String(profileStore.profile.dailyCalories))
        _dailyProtein = State(initialValue: String(profileStore.profile.dailyProtein))
        _weeklyWorkouts = State(initialValue: String(profileStore.profile.weeklyWorkoutGoal))
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Body Stats") {
                    HStack {
                        Text("Current Weight (lbs)")
                        Spacer()
                        TextField("181", text: $currentWeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }

                    HStack {
                        Text("Goal Weight (lbs)")
                        Spacer()
                        TextField("175", text: $goalWeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }

                    HStack {
                        Text("Height (inches)")
                        Spacer()
                        TextField("72", text: $height)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section {
                    HStack {
                        Text("Goal Type")
                        Spacer()
                        Text(calculatedGoalType.rawValue)
                            .foregroundColor(calculatedGoalType.color)
                            .fontWeight(.semibold)
                    }
                } header: {
                    Text("Calculated Goal")
                } footer: {
                    Text("Goal type is automatically determined based on your current and target weight.")
                }

                Section("Nutrition Goals") {
                    HStack {
                        Text("Daily Calories")
                        Spacer()
                        TextField("2000", text: $dailyCalories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }

                    HStack {
                        Text("Daily Protein (g)")
                        Spacer()
                        TextField("150", text: $dailyProtein)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("Fitness Goals") {
                    HStack {
                        Text("Weekly Workouts")
                        Spacer()
                        TextField("4", text: $weeklyWorkouts)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
            }
            .navigationTitle("Goals & Targets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                }
            }
        }
    }

    private var calculatedGoalType: GoalType {
        guard let current = Double(currentWeight),
              let goal = Double(goalWeight) else {
            return .maintain
        }

        if goal < current {
            return .cut
        } else if goal > current {
            return .bulk
        } else {
            return .maintain
        }
    }

    private func saveProfile() {
        if let current = Double(currentWeight) {
            profileStore.profile.currentWeight = current
        }
        if let goal = Double(goalWeight) {
            profileStore.profile.goalWeight = goal
        }
        if let heightValue = Double(height) {
            profileStore.profile.height = heightValue
        }
        if let calories = Int(dailyCalories) {
            profileStore.profile.dailyCalories = calories
        }
        if let protein = Int(dailyProtein) {
            profileStore.profile.dailyProtein = protein
        }
        if let workouts = Int(weeklyWorkouts) {
            profileStore.profile.weeklyWorkoutGoal = workouts
        }

        // Sync nutrition goals with NutritionStore
        nutritionStore.syncNutritionGoalsFromProfile()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
        .environmentObject(ThemeManager())
}