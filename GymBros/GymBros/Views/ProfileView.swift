import SwiftUI

struct ProfileView: View {
    @StateObject private var profileData = ProfileData()
    @State private var showingEditProfile = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(profileData.name)
                                .font(.title2)
                                .fontWeight(.semibold)

                            if !profileData.email.isEmpty {
                                Text(profileData.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Button("Edit") {
                            showingEditProfile = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 8)
                }

                Section("Stats") {
                    HStack {
                        Label("Age", systemImage: "calendar")
                        Spacer()
                        Text(profileData.age > 0 ? "\(profileData.age)" : "Not set")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Height", systemImage: "ruler")
                        Spacer()
                        Text(profileData.height > 0 ? "\(Int(profileData.height)) cm" : "Not set")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Weight", systemImage: "scalemass")
                        Spacer()
                        Text(profileData.weight > 0 ? "\(Int(profileData.weight)) kg" : "Not set")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Fitness Goals") {
                    HStack {
                        Label("Primary Goal", systemImage: "target")
                        Spacer()
                        Text(profileData.fitnessGoal.isEmpty ? "Not set" : profileData.fitnessGoal)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Weekly Workouts", systemImage: "dumbbell")
                        Spacer()
                        Text(profileData.weeklyWorkoutGoal > 0 ? "\(profileData.weeklyWorkoutGoal) per week" : "Not set")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Preferences") {
                    HStack {
                        Label("Units", systemImage: "ruler.fill")
                        Spacer()
                        Text(profileData.preferredUnits)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("Experience Level", systemImage: "star.fill")
                        Spacer()
                        Text(profileData.experienceLevel)
                            .foregroundColor(.secondary)
                    }
                }

                Section("App") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Button(action: {}) {
                        Label("Support", systemImage: "questionmark.circle")
                    }

                    Button(action: {}) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(profileData: profileData)
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profileData: ProfileData

    @State private var name: String
    @State private var email: String
    @State private var age: String
    @State private var height: String
    @State private var weight: String
    @State private var fitnessGoal: String
    @State private var weeklyWorkoutGoal: String
    @State private var preferredUnits: String
    @State private var experienceLevel: String

    init(profileData: ProfileData) {
        self.profileData = profileData
        _name = State(initialValue: profileData.name)
        _email = State(initialValue: profileData.email)
        _age = State(initialValue: profileData.age > 0 ? "\(profileData.age)" : "")
        _height = State(initialValue: profileData.height > 0 ? "\(Int(profileData.height))" : "")
        _weight = State(initialValue: profileData.weight > 0 ? "\(Int(profileData.weight))" : "")
        _fitnessGoal = State(initialValue: profileData.fitnessGoal)
        _weeklyWorkoutGoal = State(initialValue: profileData.weeklyWorkoutGoal > 0 ? "\(profileData.weeklyWorkoutGoal)" : "")
        _preferredUnits = State(initialValue: profileData.preferredUnits)
        _experienceLevel = State(initialValue: profileData.experienceLevel)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Personal Info") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                }

                Section("Physical Stats") {
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.numberPad)
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.numberPad)
                }

                Section("Fitness") {
                    Picker("Primary Goal", selection: $fitnessGoal) {
                        Text("Build Muscle").tag("Build Muscle")
                        Text("Lose Weight").tag("Lose Weight")
                        Text("Get Stronger").tag("Get Stronger")
                        Text("Improve Endurance").tag("Improve Endurance")
                        Text("Stay Healthy").tag("Stay Healthy")
                    }

                    TextField("Weekly Workout Goal", text: $weeklyWorkoutGoal)
                        .keyboardType(.numberPad)
                }

                Section("Preferences") {
                    Picker("Units", selection: $preferredUnits) {
                        Text("Metric").tag("Metric")
                        Text("Imperial").tag("Imperial")
                    }

                    Picker("Experience Level", selection: $experienceLevel) {
                        Text("Beginner").tag("Beginner")
                        Text("Intermediate").tag("Intermediate")
                        Text("Advanced").tag("Advanced")
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
        }
    }

    private func saveProfile() {
        profileData.name = name
        profileData.email = email
        profileData.age = Int(age) ?? 0
        profileData.height = Double(height) ?? 0
        profileData.weight = Double(weight) ?? 0
        profileData.fitnessGoal = fitnessGoal
        profileData.weeklyWorkoutGoal = Int(weeklyWorkoutGoal) ?? 0
        profileData.preferredUnits = preferredUnits
        profileData.experienceLevel = experienceLevel

        dismiss()
    }
}

class ProfileData: ObservableObject {
    @Published var name: String = "Gym Bro"
    @Published var email: String = ""
    @Published var age: Int = 0
    @Published var height: Double = 0
    @Published var weight: Double = 0
    @Published var fitnessGoal: String = ""
    @Published var weeklyWorkoutGoal: Int = 0
    @Published var preferredUnits: String = "Metric"
    @Published var experienceLevel: String = "Beginner"
}

#Preview {
    ProfileView()
}