import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingSettings = false
    @State private var showingGoals = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeaderView(authManager: authManager)

                    QuickStatsView()

                    ProfileMenuView(
                        authManager: authManager,
                        showingSettings: $showingSettings,
                        showingGoals: $showingGoals
                    )
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingGoals) {
                GoalsView()
            }
        }
    }
}

struct ProfileHeaderView: View {
    @ObservedObject var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            VStack(spacing: 4) {
                Text(authManager.user?.email ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Fitness Enthusiast")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct QuickStatsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)

            HStack(spacing: 16) {
                QuickStatCard(icon: "figure.walk", title: "Height", value: "6'0\"")
                QuickStatCard(icon: "scalemass", title: "Weight", value: "181 lbs")
                QuickStatCard(icon: "target", title: "Goal", value: "Cut")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
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
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 30)

                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false

    var body: some View {
        NavigationView {
            Form {
                Section("Preferences") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
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
    @State private var calorieGoal = "2000"
    @State private var proteinGoal = "150"
    @State private var workoutGoal = "4"

    var body: some View {
        NavigationView {
            Form {
                Section("Nutrition Goals") {
                    HStack {
                        Text("Daily Calories")
                        Spacer()
                        TextField("2000", text: $calorieGoal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Daily Protein (g)")
                        Spacer()
                        TextField("150", text: $proteinGoal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Fitness Goals") {
                    HStack {
                        Text("Weekly Workouts")
                        Spacer()
                        TextField("4", text: $workoutGoal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Body Goals") {
                    HStack {
                        Text("Target Weight")
                        Spacer()
                        Text("180 lbs")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Goal Type")
                        Spacer()
                        Text("Cut")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager())
}