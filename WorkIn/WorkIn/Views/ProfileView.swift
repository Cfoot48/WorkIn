import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var nutritionStore: NutritionStore
    @State private var showingSettings = false
    @State private var showingGoals = false
    @State private var showingSavedRecipes = false

    var body: some View {
        NavigationView {
            if profileStore.isLoadingProfile {
                // Show loading indicator while checking onboarding status
                VStack(spacing: 20) {
                    SwiftUI.ProgressView()
                        .scaleEffect(1.5)
                        .tint(DesignSystem.Colors.primary)
                    Text("Loading profile...")
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(themeManager.backgroundColor)
            } else if !profileStore.hasCompletedOnboarding {
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
                            showingGoals: $showingGoals,
                            showingSavedRecipes: $showingSavedRecipes
                        )
                    }
                    .padding()
                }
                .background(themeManager.backgroundColor)
                .navigationBarHidden(true)
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
                .sheet(isPresented: $showingGoals) {
                    GoalsView(profileStore: profileStore, nutritionStore: nutritionStore)
                }
                .sheet(isPresented: $showingSavedRecipes) {
                    SavedRecipesView()
                }
            }
        }
    }
}

struct ProfileHeaderView: View {
    @ObservedObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var chatManager: ChatManager
    @State private var showingEditName = false
    @State private var newName = ""
    @State private var showingModerationError = false
    @State private var moderationErrorMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                HStack {
                    Text(profileStore.profile.displayName.isEmpty ? (authManager.user?.email ?? "User") : profileStore.profile.displayName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryTextColor)

                    if authManager.user?.email == "wkbf10@gmail.com" {
                        Text("(Developer)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.6, green: 0.8, blue: 1.0),
                                        Color(red: 0.8, green: 0.6, blue: 1.0),
                                        Color(red: 1.0, green: 0.7, blue: 0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }

                    Button(action: {
                        newName = profileStore.profile.displayName
                        showingEditName = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(DesignSystem.Colors.primary)
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DesignSystem.Colors.primary.opacity(0.4), lineWidth: 2)
        )
        .alert("Edit Display Name", isPresented: $showingEditName) {
            TextField("Enter your name", text: $newName)
            Button("Cancel", role: .cancel) {
                newName = ""
            }
            Button("Save") {
                Task {
                    await saveNewName()
                }
            }
        } message: {
            Text("This name will be shown in your profile and chat messages")
        }
        .alert("Inappropriate Name", isPresented: $showingModerationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(moderationErrorMessage)
        }
    }

    private func saveNewName() async {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            newName = ""
            return
        }

        // Moderate the username
        do {
            let moderationResult = try await chatManager.moderateContent(trimmedName)

            if !moderationResult.isAllowed {
                print("🚫 Username blocked: \(moderationResult.reason)")
                await MainActor.run {
                    moderationErrorMessage = "This name contains inappropriate content. Please choose a different name."
                    showingModerationError = true
                }
                return
            }

            // Name is appropriate, save it
            await MainActor.run {
                profileStore.profile.displayName = trimmedName
                newName = ""
                showingEditName = false
            }

        } catch {
            print("⚠️ Moderation error: \(error.localizedDescription)")
            // If moderation fails, use fallback client-side check
            if containsInappropriateContent(trimmedName) {
                await MainActor.run {
                    moderationErrorMessage = "This name contains inappropriate content. Please choose a different name."
                    showingModerationError = true
                }
            } else {
                // If both moderation and fallback pass, allow the name
                await MainActor.run {
                    profileStore.profile.displayName = trimmedName
                    newName = ""
                    showingEditName = false
                }
            }
        }
    }

    private func containsInappropriateContent(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        let bannedWords = ["fuck", "shit", "nigger", "cunt", "ass", "bitch", "dick", "pussy", "cock", "slut", "whore", "fag", "retard"]
        return bannedWords.contains { lowercased.contains($0) }
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DesignSystem.Colors.primary.opacity(0.4), lineWidth: 2)
        )
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
                .foregroundColor(color ?? DesignSystem.Colors.primary)

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
        .background(
            themeManager.isDarkMode
                ? Color(red: 0.22, green: 0.22, blue: 0.23)
                : themeManager.cardBackgroundColor
        )
        .cornerRadius(8)
    }
}

struct ProfileMenuView: View {
    @ObservedObject var authManager: AuthenticationManager
    @EnvironmentObject var profileStore: UserProfileStore
    @Binding var showingSettings: Bool
    @Binding var showingGoals: Bool
    @Binding var showingSavedRecipes: Bool

    var body: some View {
        VStack(spacing: 12) {
            ProfileMenuItem(
                icon: "target",
                title: "Goals & Targets",
                action: { showingGoals = true }
            )

            ProfileMenuItem(
                icon: "book.fill",
                title: "Saved Recipes",
                action: { showingSavedRecipes = true }
            )

            ProfileMenuItem(
                icon: "gear",
                title: "Settings",
                action: { showingSettings = true }
            )

            ProfileMenuItem(
                icon: "questionmark.circle",
                title: "Help & Support",
                action: {
                    if let url = URL(string: "mailto:theworkinapp@gmail.com") {
                        UIApplication.shared.open(url)
                    }
                }
            )

            // DEBUG: Reset Onboarding
            ProfileMenuItem(
                icon: "arrow.counterclockwise",
                title: "Reset Onboarding (DEBUG)",
                action: {
                    UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                    UserDefaults.standard.removeObject(forKey: "userProfile")
                    profileStore.resetProfile()
                    print("🔄 Onboarding reset - you should now see onboarding")
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
                    .foregroundColor(DesignSystem.Colors.primary)
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
            .background(themeManager.secondaryBackgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(DesignSystem.Colors.primary.opacity(0.4), lineWidth: 2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DeleteAccountButton: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var showingDeleteConfirmation = false
    @State private var showingReauthentication = false
    @State private var isDeleting = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var reauthPassword = ""
    @EnvironmentObject var themeManager: ThemeManager

    private var isGoogleUser: Bool {
        authManager.getUserProviders().contains("google.com")
    }

    private var userEmail: String {
        authManager.user?.email ?? ""
    }

    var body: some View {
        Button(action: { showingDeleteConfirmation = true }) {
            HStack {
                Image(systemName: "trash.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                    .frame(width: 30)

                Text("Delete Account")
                    .font(.body)
                    .foregroundColor(.red)

                Spacer()

                if isDeleting {
                    SwiftUI.ProgressView()
                        .tint(.red)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.6))
                }
            }
            .padding()
            .background(themeManager.secondaryBackgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red.opacity(0.4), lineWidth: 2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDeleting)
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.")
        }
        .alert("Re-authenticate Required", isPresented: $showingReauthentication) {
            if isGoogleUser {
                Button("Cancel", role: .cancel) {
                    isDeleting = false
                }
                Button("Sign in with Google") {
                    reauthenticateWithGoogle()
                }
            } else {
                SecureField("Password", text: $reauthPassword)
                Button("Cancel", role: .cancel) {
                    isDeleting = false
                    reauthPassword = ""
                }
                Button("Confirm") {
                    reauthenticateWithPassword()
                }
            }
        } message: {
            if isGoogleUser {
                Text("For security, please sign in with Google again to confirm account deletion.")
            } else {
                Text("For security, please enter your password to confirm account deletion.")
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {
                isDeleting = false
            }
        } message: {
            Text(errorMessage)
        }
    }

    private func deleteAccount() {
        isDeleting = true
        Task {
            do {
                try await authManager.deleteAccount()
                print("✅ Account deleted successfully")
            } catch let error as AccountDeletionError {
                if case .requiresRecentLogin = error {
                    await MainActor.run {
                        showingReauthentication = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    showError = true
                    isDeleting = false
                }
            }
        }
    }

    private func reauthenticateWithPassword() {
        Task {
            do {
                try await authManager.reauthenticateForDeletion(email: userEmail, password: reauthPassword)
                reauthPassword = ""
                // Try deleting again after successful re-auth
                try await authManager.deleteAccount()
                print("✅ Account deleted successfully after re-authentication")
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    showError = true
                    isDeleting = false
                    reauthPassword = ""
                }
            }
        }
    }

    private func reauthenticateWithGoogle() {
        Task {
            do {
                try await authManager.reauthenticateWithGoogleForDeletion()
                // Try deleting again after successful re-auth
                try await authManager.deleteAccount()
                print("✅ Account deleted successfully after re-authentication")
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    showError = true
                    isDeleting = false
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var notificationsEnabled = true
    @State private var showingSignOutConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var showingReauthentication = false
    @State private var isDeleting = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var reauthPassword = ""

    private var isGoogleUser: Bool {
        authManager.getUserProviders().contains("google.com")
    }

    private var userEmail: String {
        authManager.user?.email ?? ""
    }

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
                    Button("Sign Out") {
                        showingSignOutConfirmation = true
                    }
                    .foregroundColor(.red)

                    Button("Delete Account") {
                        showingDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                    .disabled(isDeleting)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Sign Out", isPresented: $showingSignOutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    do {
                        try authManager.signOut()
                        dismiss()
                    } catch {
                        print("Error signing out: \(error)")
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.")
            }
            .alert("Re-authenticate Required", isPresented: $showingReauthentication) {
                if isGoogleUser {
                    Button("Cancel", role: .cancel) {
                        isDeleting = false
                    }
                    Button("Sign in with Google") {
                        reauthenticateWithGoogle()
                    }
                } else {
                    SecureField("Password", text: $reauthPassword)
                    Button("Cancel", role: .cancel) {
                        isDeleting = false
                        reauthPassword = ""
                    }
                    Button("Confirm") {
                        reauthenticateWithPassword()
                    }
                }
            } message: {
                if isGoogleUser {
                    Text("For security, please sign in with Google again to confirm account deletion.")
                } else {
                    Text("For security, please enter your password to confirm account deletion.")
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {
                    isDeleting = false
                }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func deleteAccount() {
        isDeleting = true
        Task {
            do {
                try await authManager.deleteAccount()
                print("✅ Account deleted successfully")
            } catch let error as AccountDeletionError {
                if case .requiresRecentLogin = error {
                    await MainActor.run {
                        showingReauthentication = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    showError = true
                    isDeleting = false
                }
            }
        }
    }

    private func reauthenticateWithPassword() {
        Task {
            do {
                try await authManager.reauthenticateForDeletion(email: userEmail, password: reauthPassword)
                reauthPassword = ""
                try await authManager.deleteAccount()
                print("✅ Account deleted successfully after re-authentication")
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    showError = true
                    isDeleting = false
                    reauthPassword = ""
                }
            }
        }
    }

    private func reauthenticateWithGoogle() {
        Task {
            do {
                try await authManager.reauthenticateWithGoogleForDeletion()
                try await authManager.deleteAccount()
                print("✅ Account deleted successfully after re-authentication")
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    showError = true
                    isDeleting = false
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

// MARK: - Saved Recipes View
struct SavedRecipesView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var templateStore: TemplateStore
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedRecipe: MealTemplate?

    var body: some View {
        NavigationView {
            VStack {
                if templateStore.mealTemplates.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.secondaryTextColor)

                        Text("No Saved Recipes")
                            .font(.headline)
                            .foregroundColor(themeManager.primaryTextColor)

                        Text("Generate recipes in the AI Assistant tab to save them here")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(templateStore.mealTemplates) { template in
                            SavedRecipeRow(template: template) {
                                selectedRecipe = template
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    templateStore.deleteMealTemplate(template)
                                } label: {
                                    Label("Delete Recipe", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: deleteRecipes)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("Saved Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailLogView(recipe: recipe)
            }
        }
    }

    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            templateStore.deleteMealTemplate(templateStore.mealTemplates[index])
        }
    }
}

// MARK: - Saved Recipe Row
struct SavedRecipeRow: View {
    let template: MealTemplate
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var totalCalories: Double {
        template.foods.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        template.foods.reduce(0) { $0 + $1.protein }
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)

                    HStack(spacing: 16) {
                        Label("\(Int(totalCalories)) cal", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Label("\(Int(totalProtein))g protein", systemImage: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recipe Detail & Log View
struct RecipeDetailLogView: View {
    @Environment(\.dismiss) private var dismiss
    let recipe: MealTemplate
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedMealType: MealType = .breakfast
    @State private var showingConfirmation = false

    var totalCalories: Double {
        recipe.foods.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        recipe.foods.reduce(0) { $0 + $1.protein }
    }

    var totalCarbs: Double {
        recipe.foods.reduce(0) { $0 + $1.carbs }
    }

    var totalFat: Double {
        recipe.foods.reduce(0) { $0 + $1.fat }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Recipe Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(recipe.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryTextColor)

                        if let servings = recipe.servings {
                            Text("\(servings) serving\(servings > 1 ? "s" : "")")
                                .font(.subheadline)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }

                        // Nutrition Summary
                        HStack(spacing: 20) {
                            NutritionInfoBadge(value: Int(totalCalories), label: "cal", color: .orange)
                            NutritionInfoBadge(value: Int(totalProtein), label: "P", color: .red)
                            NutritionInfoBadge(value: Int(totalCarbs), label: "C", color: .blue)
                            NutritionInfoBadge(value: Int(totalFat), label: "F", color: .green)
                        }
                    }
                    .padding()
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(12)

                    // Ingredients
                    if let ingredients = recipe.ingredients, !ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ingredients")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryTextColor)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(ingredients, id: \.self) { ingredient in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .foregroundColor(themeManager.secondaryTextColor)
                                        Text(ingredient)
                                            .font(.subheadline)
                                            .foregroundColor(themeManager.secondaryTextColor)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(themeManager.secondaryBackgroundColor)
                        .cornerRadius(12)
                    }

                    // Instructions
                    if let instructions = recipe.instructions, !instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Instructions")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryTextColor)

                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("\(index + 1).")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(themeManager.accentColor)
                                        Text(instruction)
                                            .font(.subheadline)
                                            .foregroundColor(themeManager.secondaryTextColor)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(themeManager.secondaryBackgroundColor)
                        .cornerRadius(12)
                    }

                    // Meal Type Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Meal Type")
                            .font(.headline)
                            .foregroundColor(themeManager.primaryTextColor)

                        Picker("Meal Type", selection: $selectedMealType) {
                            ForEach(MealType.allCases, id: \.self) { mealType in
                                Text(mealType.rawValue).tag(mealType)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding()
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(12)

                    // Log Button
                    Button(action: { showingConfirmation = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Log to Nutrition Tracker")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.cyan, Color(red: 0.3, green: 0.5, blue: 1.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("Recipe Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Log Recipe", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Log") {
                    logRecipe()
                    dismiss()
                }
            } message: {
                Text("Add '\(recipe.name)' to your \(selectedMealType.rawValue) nutrition log?")
            }
        }
    }

    private func logRecipe() {
        print("📝 PROFILE VIEW: Logging recipe '\(recipe.name)' with selected meal type: \(selectedMealType.rawValue)")
        for food in recipe.foods {
            var modifiedFood = food
            modifiedFood.mealType = selectedMealType
            print("📝 PROFILE VIEW: Setting food '\(modifiedFood.name)' mealType to \(modifiedFood.mealType.rawValue)")
            nutritionStore.addFoodEntry(modifiedFood)
        }
        print("📝 PROFILE VIEW: Finished logging recipe '\(recipe.name)'")
    }
}

// MARK: - Nutrition Info Badge
struct NutritionInfoBadge: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
        .environmentObject(ThemeManager())
}