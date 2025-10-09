import SwiftUI

struct OnboardingView: View {
    @ObservedObject var profileStore: UserProfileStore
    @Binding var isCompleted: Bool
    @EnvironmentObject var themeManager: ThemeManager

    @State private var currentPage = 0
    @State private var displayName = ""
    @State private var height = ""
    @State private var currentWeight = ""
    @State private var goalWeight = ""
    @State private var age = ""
    @State private var gender: Gender = .male
    @State private var activityLevel: ActivityLevel = .moderate
    @State private var weightChangeRate: WeightChangeRate = .moderate
    @State private var weeklyWorkouts = "4"
    @State private var proteinGoal = "150"

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    themeManager.backgroundColor,
                    Color.cyan.opacity(0.05),
                    Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.08),
                    themeManager.backgroundColor
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<7) { index in
                        Capsule()
                            .fill(index <= currentPage ?
                                LinearGradient(
                                    gradient: Gradient(colors: [.cyan, Color(red: 0.3, green: 0.5, blue: 1.0)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 6)
                            .shadow(color: index <= currentPage ? Color.cyan.opacity(0.3) : .clear, radius: 4)
                    }
                }
                .padding()

            TabView(selection: $currentPage) {
                WelcomePage()
                    .tag(0)

                DisplayNamePage(displayName: $displayName)
                    .tag(1)
                    .onAppear {
                        // Don't dismiss keyboard when appearing on this page
                    }
                    .onDisappear {
                        // Dismiss keyboard when leaving this page
                        hideKeyboard()
                    }

                BodyStatsPage(
                    height: $height,
                    currentWeight: $currentWeight,
                    age: $age,
                    gender: $gender
                )
                .tag(2)

                GoalWeightPage(
                    currentWeight: currentWeight,
                    goalWeight: $goalWeight,
                    weightChangeRate: $weightChangeRate
                )
                .tag(3)

                ActivityPage(
                    activityLevel: $activityLevel,
                    weeklyWorkouts: $weeklyWorkouts
                )
                .tag(4)

                NutritionGoalsPage(
                    currentWeight: currentWeight,
                    goalWeight: goalWeight,
                    height: height,
                    weightChangeRate: weightChangeRate,
                    activityLevel: activityLevel,
                    gender: gender,
                    age: age,
                    proteinGoal: $proteinGoal
                )
                .tag(5)

                RatingAndContactPage()
                    .tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

                // Navigation buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.secondaryBackgroundColor)
                            .foregroundColor(themeManager.primaryTextColor)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }

                    Button(action: {
                        if currentPage < 6 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        HStack {
                            Text(currentPage < 6 ? "Next" : "Complete")
                            Image(systemName: currentPage < 6 ? "chevron.right" : "checkmark")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.cyan, Color(red: 0.3, green: 0.5, blue: 1.0)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.cyan.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .disabled(!canProceed)
                    .opacity(canProceed ? 1.0 : 0.5)
                }
                .padding()
            }
        }
    }

    private var canProceed: Bool {
        switch currentPage {
        case 0: return true
        case 1: return !displayName.isEmpty
        case 2: return !height.isEmpty && !currentWeight.isEmpty && !age.isEmpty
        case 3: return !goalWeight.isEmpty
        case 4: return !weeklyWorkouts.isEmpty
        case 5: return !proteinGoal.isEmpty
        case 6: return true
        default: return false
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func completeOnboarding() {
        guard let heightValue = Double(height),
              let currentWeightValue = Double(currentWeight),
              let goalWeightValue = Double(goalWeight),
              let ageValue = Int(age),
              let weeklyWorkoutsValue = Int(weeklyWorkouts),
              let proteinValue = Int(proteinGoal) else {
            return
        }

        // Calculate calories based on goal
        let calculatedCalories = calculateDailyCalories(
            currentWeight: currentWeightValue,
            goalWeight: goalWeightValue,
            height: heightValue,
            age: ageValue,
            gender: gender,
            activityLevel: activityLevel,
            weightChangeRate: weightChangeRate
        )

        // Update profile
        profileStore.profile.displayName = displayName
        profileStore.profile.height = heightValue
        profileStore.profile.currentWeight = currentWeightValue
        profileStore.profile.goalWeight = goalWeightValue
        profileStore.profile.dailyCalories = calculatedCalories
        profileStore.profile.dailyProtein = proteinValue
        profileStore.profile.weeklyWorkoutGoal = weeklyWorkoutsValue

        // Mark onboarding as complete
        isCompleted = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    private func calculateDailyCalories(
        currentWeight: Double,
        goalWeight: Double,
        height: Double,
        age: Int,
        gender: Gender,
        activityLevel: ActivityLevel,
        weightChangeRate: WeightChangeRate
    ) -> Int {
        // Calculate BMR using Mifflin-St Jeor Equation
        let weightKg = currentWeight * 0.453592
        let heightCm = height * 2.54

        let bmr: Double
        if gender == .male {
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) - 161
        }

        // Apply activity multiplier
        let tdee = bmr * activityLevel.multiplier

        // Determine if cutting or bulking
        let isDeficit = goalWeight < currentWeight

        // Calculate calorie adjustment based on weight change rate
        // Safe ranges: 250-1000 cal deficit, 200-500 cal surplus
        let calorieAdjustment: Double
        switch weightChangeRate {
        case .slow:
            calorieAdjustment = isDeficit ? -250 : 200  // 0.5 lbs/week
        case .moderate:
            calorieAdjustment = isDeficit ? -500 : 300  // 1 lb/week
        case .fast:
            calorieAdjustment = isDeficit ? -750 : 400  // 1.5 lbs/week
        }

        let targetCalories = tdee + calorieAdjustment

        // Ensure minimum calories (1200 for women, 1500 for men)
        let minimumCalories = gender == .male ? 1500.0 : 1200.0
        let maximumCalories = tdee + 500 // Cap surplus at +500

        let finalCalories = max(minimumCalories, min(targetCalories, maximumCalories))

        return Int(finalCalories)
    }
}

// MARK: - Supporting Types

enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "Sedentary (little to no exercise)"
    case light = "Light (1-3 workouts/week)"
    case moderate = "Moderate (3-5 workouts/week)"
    case active = "Active (6-7 workouts/week)"
    case veryActive = "Very Active (athlete)"

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}

enum WeightChangeRate: String, CaseIterable, Codable {
    case slow = "Slow (0.5 lbs/week)"
    case moderate = "Moderate (1 lb/week)"
    case fast = "Fast (1.5 lbs/week)"
}

// MARK: - Onboarding Pages

struct WelcomePage: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.cyan.opacity(0.2), Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)

                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.cyan, Color(red: 0.3, green: 0.5, blue: 1.0)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.3), radius: 10)
            }

            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(themeManager.secondaryTextColor)

                Text("WORKIN")
                    .font(.system(size: 48, weight: .heavy, design: .default))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.cyan, Color(red: 0.3, green: 0.5, blue: 1.0)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.3), radius: 8)

                Text("Let's personalize your fitness journey")
                    .font(.title3)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}

struct DisplayNamePage: View {
    @Binding var displayName: String

    var body: some View {
        VStack(spacing: 24) {
            Text("Choose Your Name")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Name")
                        .font(.headline)
                    TextField("Enter your name", text: $displayName)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                    Text("This will be shown in your profile and chat messages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

struct BodyStatsPage: View {
    @Binding var height: String
    @Binding var currentWeight: String
    @Binding var age: String
    @Binding var gender: Gender

    var body: some View {
        VStack(spacing: 24) {
            Text("Tell us about yourself")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Height (inches)")
                        .font(.headline)
                    TextField("72", text: $height)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    Text("Example: 6'0\" = 72 inches")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Weight (lbs)")
                        .font(.headline)
                    TextField("180", text: $currentWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Age")
                        .font(.headline)
                    TextField("25", text: $age)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Gender")
                        .font(.headline)
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

struct GoalWeightPage: View {
    let currentWeight: String
    @Binding var goalWeight: String
    @Binding var weightChangeRate: WeightChangeRate

    var goalType: String {
        guard let current = Double(currentWeight),
              let goal = Double(goalWeight) else {
            return "Maintain"
        }

        if goal < current {
            return "Cut (Lose Weight)"
        } else if goal > current {
            return "Bulk (Gain Weight)"
        } else {
            return "Maintain Weight"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("What's your goal?")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                if let current = Double(currentWeight) {
                    Text("Current Weight: \(Int(current)) lbs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal Weight (lbs)")
                        .font(.headline)
                    TextField("175", text: $goalWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }

                // Show goal type
                if !goalWeight.isEmpty {
                    HStack {
                        Text("Goal Type:")
                            .font(.headline)
                        Spacer()
                        Text(goalType)
                            .font(.headline)
                            .foregroundColor(goalTypeColor)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("How quickly do you want to reach your goal?")
                        .font(.headline)

                    Picker("Rate", selection: $weightChangeRate) {
                        ForEach(WeightChangeRate.allCases, id: \.self) { rate in
                            Text(rate.rawValue).tag(rate)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("We'll calculate safe calorie targets based on your selection")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            Spacer()
        }
        .padding()
    }

    private var goalTypeColor: Color {
        guard let current = Double(currentWeight),
              let goal = Double(goalWeight) else {
            return .blue
        }

        if goal < current {
            return .red
        } else if goal > current {
            return .green
        } else {
            return .blue
        }
    }
}

struct ActivityPage: View {
    @Binding var activityLevel: ActivityLevel
    @Binding var weeklyWorkouts: String

    var body: some View {
        VStack(spacing: 24) {
            Text("Activity Level")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How active are you?")
                        .font(.headline)

                    Picker("Activity Level", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 200)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Weekly Workout Goal")
                        .font(.headline)
                    TextField("4", text: $weeklyWorkouts)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Text("How many times per week do you want to workout?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            Spacer()
        }
        .padding()
    }
}

struct NutritionGoalsPage: View {
    let currentWeight: String
    let goalWeight: String
    let height: String
    let weightChangeRate: WeightChangeRate
    let activityLevel: ActivityLevel
    let gender: Gender
    let age: String
    @Binding var proteinGoal: String

    var calculatedCalories: Int {
        guard let current = Double(currentWeight),
              let goal = Double(goalWeight),
              let heightValue = Double(height),
              let ageValue = Int(age) else {
            return 2000
        }

        let weightKg = current * 0.453592
        let heightCm = heightValue * 2.54

        let bmr: Double
        if gender == .male {
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(ageValue)) + 5
        } else {
            bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(ageValue)) - 161
        }

        let tdee = bmr * activityLevel.multiplier
        let isDeficit = goal < current

        let calorieAdjustment: Double
        switch weightChangeRate {
        case .slow:
            calorieAdjustment = isDeficit ? -250 : 200
        case .moderate:
            calorieAdjustment = isDeficit ? -500 : 300
        case .fast:
            calorieAdjustment = isDeficit ? -750 : 400
        }

        let targetCalories = tdee + calorieAdjustment
        let minimumCalories = gender == .male ? 1500.0 : 1200.0
        let maximumCalories = tdee + 500

        return Int(max(minimumCalories, min(targetCalories, maximumCalories)))
    }

    var recommendedProtein: Int {
        guard let weight = Double(currentWeight) else { return 150 }
        // 0.8-1g per lb of bodyweight
        return Int(weight * 0.9)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Nutrition Goals")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Calorie Target")
                        .font(.headline)

                    HStack {
                        Text("\(calculatedCalories)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.cyan, Color(red: 0.3, green: 0.5, blue: 1.0)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("cal/day")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }

                    Text("Based on your stats and goals, we recommend this daily calorie intake")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.cyan.opacity(0.1), Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Protein Goal (g)")
                        .font(.headline)

                    TextField("\(recommendedProtein)", text: $proteinGoal)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                    Text("Recommended: \(recommendedProtein)g (0.9g per lb bodyweight)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            Spacer()
        }
        .padding()
        .onAppear {
            if proteinGoal.isEmpty {
                proteinGoal = String(recommendedProtein)
            }
        }
    }
}

struct RatingAndContactPage: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Star icon with gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 150)
                        .blur(radius: 30)

                    Image(systemName: "star.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.5), radius: 10)
                }
                .padding(.top, 20)

                // Title
                Text("Like the App?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.primaryTextColor)
                    .multilineTextAlignment(.center)

                // Rating section
                VStack(spacing: 16) {
                    Text("We'd love your feedback!")
                        .font(.title3)
                        .foregroundColor(themeManager.primaryTextColor)
                        .multilineTextAlignment(.center)

                    Text("Please rate us 5 stars on the App Store")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(themeManager.secondaryTextColor)

                    // Star rating visual
                    HStack(spacing: 8) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.3), radius: 4)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)

                // Contact section
                VStack(spacing: 12) {
                    Text("Questions or Suggestions?")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)

                    VStack(spacing: 8) {
                        Text("Message us at:")
                            .font(.subheadline)
                            .foregroundColor(themeManager.secondaryTextColor)

                        Button(action: {
                            if let url = URL(string: "mailto:TheWorkInApp@gmail.com") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("TheWorkInApp@gmail.com")
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.cyan, Color(red: 0.3, green: 0.5, blue: 1.0)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        }
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.cyan.opacity(0.1), Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
            .padding()
        }
    }
}

#Preview {
    OnboardingView(
        profileStore: UserProfileStore(),
        isCompleted: .constant(false)
    )
}
