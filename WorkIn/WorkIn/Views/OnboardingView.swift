import SwiftUI

struct OnboardingView: View {
    @ObservedObject var profileStore: UserProfileStore
    @Binding var isCompleted: Bool
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var chatManager: ChatManager
    @Environment(\.colorScheme) var colorScheme

    @State private var currentPage = 0
    @State private var displayName = ""
    @State private var showingModerationError = false
    @State private var moderationErrorMessage = ""
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
            // Background
            DesignSystem.Colors.background(for: colorScheme)
                .ignoresSafeArea()

            VStack {
                // Progress indicator - hidden on first page
                if currentPage > 0 {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        ForEach(0..<6) { index in
                            Capsule()
                                .fill(index < currentPage ? DesignSystem.Colors.primary : Color.gray.opacity(0.3))
                                .frame(height: 6)
                                .shadow(color: index < currentPage ? DesignSystem.Colors.primary.opacity(0.3) : .clear, radius: 4)
                                .animation(DesignSystem.Animation.spring, value: currentPage)
                        }
                    }
                    .padding(DesignSystem.Spacing.md)
                }

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
                    .onAppear {
                        hideKeyboard()
                    }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

                // Navigation buttons
                HStack(spacing: DesignSystem.Spacing.md) {
                    if currentPage > 0 {
                        DSButton("Back", icon: "chevron.left", style: .outline, size: .large) {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                    }

                    DSButton(
                        currentPage == 0 ? "Start" : (currentPage < 6 ? "Next" : "Complete"),
                        icon: currentPage == 0 ? "arrow.right" : (currentPage < 6 ? "chevron.right" : "checkmark"),
                        style: .primary,
                        size: .large
                    ) {
                        if currentPage < 6 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            Task {
                                await completeOnboarding()
                            }
                        }
                    }
                    .disabled(!canProceed)
                    .opacity(canProceed ? 1.0 : 0.5)
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }
        .alert("Inappropriate Name", isPresented: $showingModerationError) {
            Button("OK", role: .cancel) {
                // Go back to display name page
                withAnimation {
                    currentPage = 1
                }
            }
        } message: {
            Text(moderationErrorMessage)
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

    private func completeOnboarding() async {
        guard let heightValue = Double(height),
              let currentWeightValue = Double(currentWeight),
              let goalWeightValue = Double(goalWeight),
              let ageValue = Int(age),
              let weeklyWorkoutsValue = Int(weeklyWorkouts),
              let proteinValue = Int(proteinGoal) else {
            return
        }

        // Moderate the display name before allowing onboarding completion
        do {
            let moderationResult = try await chatManager.moderateContent(displayName)

            if !moderationResult.isAllowed {
                print("🚫 Onboarding: Username blocked: \(moderationResult.reason)")
                await MainActor.run {
                    moderationErrorMessage = "The display name '\(displayName)' contains inappropriate content. Please choose a different name."
                    showingModerationError = true
                }
                return
            }

        } catch {
            print("⚠️ Onboarding: Moderation error: \(error.localizedDescription)")
            // If moderation fails, use fallback client-side check
            if containsInappropriateContent(displayName) {
                await MainActor.run {
                    moderationErrorMessage = "The display name '\(displayName)' contains inappropriate content. Please choose a different name."
                    showingModerationError = true
                }
                return
            }
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
        await MainActor.run {
            profileStore.profile.displayName = displayName
            profileStore.profile.height = heightValue
            profileStore.profile.currentWeight = currentWeightValue
            profileStore.profile.goalWeight = goalWeightValue
            profileStore.profile.dailyCalories = calculatedCalories
            profileStore.profile.dailyProtein = proteinValue
            profileStore.profile.weeklyWorkoutGoal = weeklyWorkoutsValue

            // Mark onboarding as complete
            isCompleted = true
        }

        // Force save profile to Firestore after onboarding completes
        await profileStore.saveProfileExplicitly()
    }

    private func containsInappropriateContent(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        let bannedWords = ["fuck", "shit", "nigger", "cunt", "ass", "bitch", "dick", "pussy", "cock", "slut", "whore", "fag", "retard"]
        return bannedWords.contains { lowercased.contains($0) }
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

        // Determine if cutting, bulking, or maintaining
        let isDeficit = goalWeight < currentWeight
        let isMaintaining = abs(goalWeight - currentWeight) < 1.0 // Within 1 lb is maintenance

        // Calculate calorie adjustment based on weight change rate
        // Safe ranges: 250-1000 cal deficit, 200-500 cal surplus, 0 for maintenance
        let calorieAdjustment: Double
        if isMaintaining {
            calorieAdjustment = 0  // No adjustment for maintenance
        } else {
            switch weightChangeRate {
            case .slow:
                calorieAdjustment = isDeficit ? -250 : 200  // 0.5 lbs/week
            case .moderate:
                calorieAdjustment = isDeficit ? -500 : 300  // 1 lb/week
            case .fast:
                calorieAdjustment = isDeficit ? -750 : 400  // 1.5 lbs/week
            }
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
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxxl) {
            Spacer()
            Spacer()
            Spacer()

            // Lottie Animation - smaller size
            #if canImport(Lottie)
            LottieView(fileName: "WorkIn Final", loopMode: .loop, animationSpeed: 1.0)
                .frame(width: 200, height: 200)
                .scaleEffect(0.45)
            #else
            LottieView(fileName: "WorkIn Final")
                .frame(width: 200, height: 200)
                .scaleEffect(0.45)
            #endif

            VStack(spacing: DesignSystem.Spacing.md) {
                Text("Welcome to")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))

                Text("WORKIN")
                    .font(.system(size: 48, weight: .heavy, design: .default))
                    .foregroundColor(DesignSystem.Colors.primary)
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.5), radius: 20, x: 0, y: 0)
                    .shadow(color: DesignSystem.Colors.primary.opacity(0.35), radius: 35, x: 0, y: 0)

                Text("Let's personalize your fitness journey")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }

            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
    }
}

struct DisplayNamePage: View {
    @Binding var displayName: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Text("Choose Your Name")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Display Name")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                    TextField("Enter your name", text: $displayName)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                    Text("This will be shown in your profile and chat messages")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }
            }
            .padding(DesignSystem.Spacing.lg)

            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
    }
}

struct BodyStatsPage: View {
    @Binding var height: String
    @Binding var currentWeight: String
    @Binding var age: String
    @Binding var gender: Gender
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Text("Tell us about yourself")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Height (inches)")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                    TextField("72", text: $height)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    Text("Example: 6'0\" = 72 inches")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Current Weight (lbs)")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                    TextField("180", text: $currentWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Age")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                    TextField("25", text: $age)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Gender")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding(DesignSystem.Spacing.lg)

            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
    }
}

struct GoalWeightPage: View {
    let currentWeight: String
    @Binding var goalWeight: String
    @Binding var weightChangeRate: WeightChangeRate
    @Environment(\.colorScheme) var colorScheme

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
        VStack(spacing: DesignSystem.Spacing.xl) {
            Text("What's your goal?")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                if let current = Double(currentWeight) {
                    Text("Current Weight: \(Int(current)) lbs")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Goal Weight (lbs)")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                    TextField("175", text: $goalWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }

                // Show goal type
                if !goalWeight.isEmpty {
                    HStack {
                        Text("Goal Type:")
                            .font(DesignSystem.Typography.bodyBold)
                            .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                        Spacer()
                        Text(goalType)
                            .font(DesignSystem.Typography.bodyBold)
                            .foregroundColor(goalTypeColor)
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.card(for: colorScheme))
                    .cornerRadius(DesignSystem.CornerRadius.sm)
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("How quickly do you want to reach your goal?")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                    Picker("Rate", selection: $weightChangeRate) {
                        ForEach(WeightChangeRate.allCases, id: \.self) { rate in
                            Text(rate.rawValue).tag(rate)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("We'll calculate safe calorie targets based on your selection")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }
            }
            .padding(DesignSystem.Spacing.lg)

            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
    }

    private var goalTypeColor: Color {
        guard let current = Double(currentWeight),
              let goal = Double(goalWeight) else {
            return DesignSystem.Colors.primary
        }

        if goal < current {
            return .red
        } else if goal > current {
            return .green
        } else {
            return DesignSystem.Colors.primary
        }
    }
}

struct ActivityPage: View {
    @Binding var activityLevel: ActivityLevel
    @Binding var weeklyWorkouts: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Text("Activity Level")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("How active are you?")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                    Picker("Activity Level", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 200)
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Weekly Workout Goal")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                    TextField("4", text: $weeklyWorkouts)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Text("How many times per week do you want to workout?")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }
            }
            .padding(DesignSystem.Spacing.lg)

            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
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
    @Environment(\.colorScheme) var colorScheme

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
        let isMaintaining = abs(goal - current) < 1.0 // Within 1 lb is maintenance

        let calorieAdjustment: Double
        if isMaintaining {
            calorieAdjustment = 0  // No adjustment for maintenance
        } else {
            switch weightChangeRate {
            case .slow:
                calorieAdjustment = isDeficit ? -250 : 200
            case .moderate:
                calorieAdjustment = isDeficit ? -500 : 300
            case .fast:
                calorieAdjustment = isDeficit ? -750 : 400
            }
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
        VStack(spacing: DesignSystem.Spacing.xl) {
            Text("Nutrition Goals")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Daily Calorie Target")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                    HStack {
                        Text("\(calculatedCalories)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.primary)
                        Text("cal/day")
                            .font(DesignSystem.Typography.bodyBold)
                            .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                    }

                    Text("Based on your stats and goals, we recommend this daily calorie intake")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.card(for: colorScheme))
                .cornerRadius(DesignSystem.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Daily Protein Goal (g)")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                    TextField("\(recommendedProtein)", text: $proteinGoal)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                    Text("Recommended: \(recommendedProtein)g (0.9g per lb bodyweight)")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))
                }
            }
            .padding(DesignSystem.Spacing.lg)

            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .onAppear {
            if proteinGoal.isEmpty {
                proteinGoal = String(recommendedProtein)
            }
        }
    }
}

struct RatingAndContactPage: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xxxl) {
                // Star icon
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 150, height: 150)
                        .blur(radius: 30)

                    Image(systemName: "star.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow.opacity(0.5), radius: 10)
                }
                .padding(.top, DesignSystem.Spacing.lg)

                // Title
                Text("Like the App?")
                    .font(DesignSystem.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                    .multilineTextAlignment(.center)

                // Rating section
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("We'd love your feedback!")
                        .font(DesignSystem.Typography.title3)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))
                        .multilineTextAlignment(.center)

                    Text("Please rate us 5 stars on the App Store")
                        .font(DesignSystem.Typography.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))

                    // Star rating visual
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(DesignSystem.Typography.title2)
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.3), radius: 4)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.xs)
                }
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.card(for: colorScheme))
                .cornerRadius(DesignSystem.CornerRadius.lg)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, DesignSystem.Spacing.lg)

                // Contact section
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Questions or Suggestions?")
                        .font(DesignSystem.Typography.bodyBold)
                        .foregroundColor(DesignSystem.Colors.textPrimary(for: colorScheme))

                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Text("Message us at:")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.textSecondary(for: colorScheme))

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
                            .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.card(for: colorScheme))
                .cornerRadius(DesignSystem.CornerRadius.lg)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, DesignSystem.Spacing.lg)

                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}

#Preview {
    OnboardingView(
        profileStore: UserProfileStore(),
        isCompleted: .constant(false)
    )
}
