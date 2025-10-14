import SwiftUI

struct ProgressView: View {
    @Binding var mainTabSelection: Int
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedWorkout: Workout?
    @State private var showingWorkoutDetail = false
    @State private var selectedTab = 0
    @State private var exerciseSearchText = ""
    @State private var expandedCategories: Set<ExerciseCategory> = []

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom header bar
                HStack {
                    Text("Progress")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.primaryTextColor)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Custom Tab Bar
                HStack {
                    TabButton(title: "Exercise", isSelected: selectedTab == 0, color: .blue) {
                        selectedTab = 0
                    }
                    TabButton(title: "Nutrition", isSelected: selectedTab == 1, color: .orange) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .background(themeManager.backgroundColor)

                // Tab Content
                TabView(selection: $selectedTab) {
                    exerciseTabContent
                        .tag(0)
                        .gesture(
                            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                                .onEnded { value in
                                    handleSwipe(value: value, currentTab: 0)
                                }
                        )

                    nutritionTabContent
                        .tag(1)
                        .gesture(
                            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                                .onEnded { value in
                                    handleSwipe(value: value, currentTab: 1)
                                }
                        )
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(themeManager.backgroundColor)
            .navigationBarHidden(true)
            .onAppear {
                // Data is automatically loaded via WorkoutStore Firebase listeners
            }
            .sheet(isPresented: $showingWorkoutDetail) {
                if let workout = selectedWorkout {
                    WorkoutDetailView(workout: workout)
                }
            }
        }
    }

    private var exerciseTabContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                VolumeChartView(workouts: workoutStore.workouts)
                    .frame(height: 200)
                    .padding()
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(12)
                    .id(workoutStore.workouts.count)

                bestMuscleRanksSection

                recentWorkoutsSection

                exerciseProgressSection
            }
            .padding()
            .background(themeManager.backgroundColor)
        }
        .background(themeManager.backgroundColor)
    }

    private var nutritionTabContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                CaloriesChartView(
                    nutritionData: nutritionStore.dailyNutrition,
                    calorieGoal: nutritionStore.nutritionGoals.dailyCalories
                )
                .frame(height: 200)
                .padding()
                .background(themeManager.secondaryBackgroundColor)
                .cornerRadius(12)
                .id(nutritionStore.dailyNutrition.count)

                weeklyMacrosSection
            }
            .padding()
            .background(themeManager.backgroundColor)
        }
        .background(themeManager.backgroundColor)
    }

    private var bestMuscleRanksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Best Muscle Ranks")
                .font(.headline)
                .padding(.horizontal)

            if workoutStore.workouts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "figure.strengthtraining.functional")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No workouts yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Complete workouts to see your best muscle ranks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                let muscleRanks = calculateBestMuscleRanks()

                if muscleRanks.isEmpty {
                    Text("Complete workouts with weighted exercises to earn ranks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        MuscleGroupDiagram(muscleGroupRanks: muscleRanks)
                            .frame(height: 350)
                            .padding()

                        // Legend showing rank colors
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rank Legend:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(StrengthRank.allCases, id: \.self) { rank in
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(rank.glowColor)
                                            .frame(width: 12, height: 12)
                                        Text(rank.rawValue)
                                            .font(.caption2)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(12)
                }
            }
        }
    }

    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Workouts")
                .font(.headline)
                .padding(.horizontal)

            if workoutStore.workouts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "figure.strengthtraining.functional")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No workouts yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Complete your first workout to see progress here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(workoutStore.workouts.prefix(5)) { workout in
                        RecentWorkoutRowView(workout: workout) {
                            selectedWorkout = workout
                            showingWorkoutDetail = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var exerciseProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Exercise Progress")
                .font(.headline)
                .padding(.horizontal)

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search exercises...", text: $exerciseSearchText)
                    .textFieldStyle(PlainTextFieldStyle())

                if !exerciseSearchText.isEmpty {
                    Button(action: { exerciseSearchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)

            if !getUniqueExercises().isEmpty {
                let groupedExercises = getGroupedExercises()

                if groupedExercises.isEmpty {
                    Text("No exercises found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            if let exercises = groupedExercises[category], !exercises.isEmpty {
                                ExerciseCategorySection(
                                    category: category,
                                    exercises: exercises,
                                    workouts: workoutStore.workouts,
                                    workoutStore: workoutStore,
                                    isExpanded: expandedCategories.contains(category),
                                    onToggle: {
                                        if expandedCategories.contains(category) {
                                            expandedCategories.remove(category)
                                        } else {
                                            expandedCategories.insert(category)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("Complete workouts to see exercise progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
    }

    private var weeklyMacrosSection: some View {
        let weeklyCalories = getWeeklyMacro(\.totalCalories)
        let weeklyProtein = getWeeklyMacro(\.totalProtein)
        let weeklyCarbs = getWeeklyMacro(\.totalCarbs)
        let weeklyFat = getWeeklyMacro(\.totalFat)

        let hasNutritionData = weeklyCalories > 0 || weeklyProtein > 0 || weeklyCarbs > 0 || weeklyFat > 0

        return Group {
            if hasNutritionData {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly Macros Summary")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        if weeklyProtein > 0 {
                            SimpleMacroRowView(
                                title: "Protein",
                                amount: weeklyProtein,
                                unit: "g",
                                color: .red
                            )
                        }

                        if weeklyCarbs > 0 {
                            SimpleMacroRowView(
                                title: "Carbs",
                                amount: weeklyCarbs,
                                unit: "g",
                                color: .blue
                            )
                        }

                        if weeklyFat > 0 {
                            SimpleMacroRowView(
                                title: "Fat",
                                amount: weeklyFat,
                                unit: "g",
                                color: .yellow
                            )
                        }

                        if weeklyCalories > 0 {
                            SimpleMacroRowView(
                                title: "Calories",
                                amount: weeklyCalories,
                                unit: "cal",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly Macros Summary")
                        .font(.headline)
                        .padding(.horizontal)

                    Text("Log some food entries to see your weekly nutrition summary")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
        }
    }

    private func calculateBestMuscleRanks() -> [String: StrengthRank] {
        var bestRanks: [String: StrengthRank] = [:]

        // Get bodyweight - use most recent workout's bodyweight if available, otherwise default
        let bodyWeight = workoutStore.workouts.first?.bodyWeight ?? 181.0

        // Iterate through all workouts and exercises to find the best rank for each muscle
        for workout in workoutStore.workouts {
            let workoutBodyWeight = workout.bodyWeight ?? bodyWeight

            for exercise in workout.exercises {
                // Calculate rank for this exercise
                let oneRepMaxes = exercise.sets.compactMap { set -> Double? in
                    guard set.reps > 0 && set.weight > 0 else { return nil }
                    if set.reps == 1 {
                        return set.weight
                    } else if set.reps >= 36 {
                        let baseRatio = 18.0
                        let extraReps = Double(set.reps) - 35.0
                        return set.weight * (baseRatio + extraReps * 0.3)
                    } else {
                        return set.weight * (36.0 / (37.0 - Double(set.reps)))
                    }
                }

                guard let maxOneRepMax = oneRepMaxes.max(), maxOneRepMax > 0 else { continue }

                let exerciseRank = StrengthStandards.getRank(
                    exerciseName: exercise.name,
                    weight: maxOneRepMax,
                    bodyWeight: workoutBodyWeight,
                    equipment: exercise.equipment
                )

                // Assign this rank to all muscle groups worked by this exercise
                // Keep the highest rank for each muscle across all workouts
                for muscleGroup in exercise.muscleGroups {
                    if let existingRank = bestRanks[muscleGroup] {
                        let currentIndex = StrengthRank.allCases.firstIndex(of: exerciseRank) ?? 0
                        let existingIndex = StrengthRank.allCases.firstIndex(of: existingRank) ?? 0
                        if currentIndex > existingIndex {
                            bestRanks[muscleGroup] = exerciseRank
                        }
                    } else {
                        bestRanks[muscleGroup] = exerciseRank
                    }
                }
            }
        }

        return bestRanks
    }

    private func getUniqueExercises() -> [String] {
        let allExercises = workoutStore.workouts.flatMap { $0.exercises.map { $0.name } }
        return Array(Set(allExercises)).sorted()
    }

    private func getGroupedExercises() -> [ExerciseCategory: [String]] {
        let allExercises = getUniqueExercises()

        // Filter by search text
        let filteredExercises = exerciseSearchText.isEmpty
            ? allExercises
            : allExercises.filter { $0.lowercased().contains(exerciseSearchText.lowercased()) }

        // Group exercises by their category from the exercise database
        var grouped: [ExerciseCategory: [String]] = [:]

        for exerciseName in filteredExercises {
            // Find the exercise in the database to get its category
            if let template = ExerciseDatabase.exercises.first(where: { $0.name == exerciseName }) {
                grouped[template.category, default: []].append(exerciseName)
            } else {
                // If not found in database, try to infer category from muscle groups or default to Push
                let category = inferCategoryFromName(exerciseName)
                grouped[category, default: []].append(exerciseName)
            }
        }

        // Sort exercises within each category
        for category in grouped.keys {
            grouped[category]?.sort()
        }

        return grouped
    }

    private func inferCategoryFromName(_ name: String) -> ExerciseCategory {
        let lowercased = name.lowercased()

        // Pull exercises
        if lowercased.contains("pull") || lowercased.contains("row") ||
           lowercased.contains("curl") || lowercased.contains("lat") ||
           lowercased.contains("deadlift") || lowercased.contains("shrug") {
            return .pull
        }

        // Legs exercises
        if lowercased.contains("squat") || lowercased.contains("leg") ||
           lowercased.contains("lunge") || lowercased.contains("calf") ||
           lowercased.contains("glute") || lowercased.contains("hamstring") {
            return .legs
        }

        // Core exercises
        if lowercased.contains("ab") || lowercased.contains("plank") ||
           lowercased.contains("crunch") || lowercased.contains("core") {
            return .core
        }

        // Default to push (chest, shoulders, triceps)
        return .push
    }

    private func getWeeklyMacro(_ keyPath: KeyPath<DailyNutrition, Double>) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        return nutritionStore.dailyNutrition
            .filter { $0.date >= weekAgo }
            .reduce(0) { total, nutrition in
                total + nutrition[keyPath: keyPath]
            }
    }

    private func handleSwipe(value: DragGesture.Value, currentTab: Int) {
        let horizontalAmount = value.translation.width
        let verticalAmount = value.translation.height

        // Only respond to horizontal swipes (ignore if too vertical)
        if abs(horizontalAmount) > abs(verticalAmount) {
            if horizontalAmount < 0 {
                // Swipe left
                if currentTab == 0 {
                    // From Exercise tab, go to internal Nutrition tab
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTab = 1
                    }
                } else if currentTab == 1 {
                    // From Nutrition tab, go to Chat main tab
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        mainTabSelection = 3
                    }
                }
            } else {
                // Swipe right
                if currentTab == 0 {
                    // From Exercise tab, go to Nutrition main tab
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        mainTabSelection = 1
                    }
                } else if currentTab == 1 {
                    // From Nutrition tab, go to internal Exercise tab
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTab = 0
                    }
                }
            }
        }
    }
}

struct RecentWorkoutRowView: View {
    let workout: Workout
    let onTap: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(workout.name)
                            .font(.headline)
                            .foregroundColor(themeManager.primaryTextColor)
                        Spacer()
                        Text(formatDate(workout.date))
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }

                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Image(systemName: "dumbbell.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("\(workout.exercises.count) exercises")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(formatDuration(workout.duration))
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("\(Int(getTotalVolume(workout))) lbs")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    }

                    if !workout.exercises.isEmpty {
                        Text(workout.exercises.map { $0.name }.joined(separator: ", "))
                            .font(.caption2)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .lineLimit(2)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .padding()
            .background(themeManager.cardBackgroundColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func getTotalVolume(_ workout: Workout) -> Double {
        return workout.exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { setTotal, set in
                setTotal + (Double(set.reps) * set.weight)
            }
        }
    }
}


struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    workoutSummaryCard

                    exercisesSection
                }
                .padding()
            }
            .navigationTitle(workout.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var workoutSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDate(workout.date))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatDuration(workout.duration))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(workout.exercises.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Volume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(getTotalVolume())) lbs")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Exercises")
                .font(.headline)

            ForEach(workout.exercises) { exercise in
                ExerciseDetailCard(exercise: exercise)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func getTotalVolume() -> Double {
        return workout.exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { setTotal, set in
                setTotal + (Double(set.reps) * set.weight)
            }
        }
    }
}

struct ExerciseDetailCard: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(exercise.sets.count) sets")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !exercise.muscleGroups.isEmpty {
                Text(exercise.muscleGroups.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }

            VStack(spacing: 8) {
                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                    HStack {
                        Text("Set \(index + 1)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .leading)

                        Text("\(set.reps) reps")
                            .font(.subheadline)
                            .frame(width: 60, alignment: .leading)

                        Text("\(Int(set.weight)) lbs")
                            .font(.subheadline)
                            .frame(width: 70, alignment: .leading)

                        Spacer()

                        Text("\(Int(Double(set.reps) * set.weight)) lbs")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(4)

                        if set.completed {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(set.completed ? Color.green.opacity(0.05) : Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(set.completed ? Color.green.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? color : .secondary)

                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? color : .clear)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MacroRowView: View {
    let title: String
    let amount: Double
    let unit: String
    let color: Color
    let target: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(Int(amount)) \(unit)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Target: \(Int(target)) \(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                let percentage = target > 0 ? (amount / target) * 100 : 0
                Text("\(Int(percentage))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(percentage >= 100 ? .green : percentage >= 80 ? .orange : .red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct SimpleMacroRowView: View {
    let title: String
    let amount: Double
    let unit: String
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(Int(amount)) \(unit)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ExerciseCategorySection: View {
    let category: ExerciseCategory
    let exercises: [String]
    let workouts: [Workout]
    @ObservedObject var workoutStore: WorkoutStore
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Category header
            Button(action: onToggle) {
                HStack {
                    Image(systemName: categoryIcon)
                        .font(.headline)
                        .foregroundColor(categoryColor)
                        .frame(width: 24)

                    Text(category.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("(\(exercises.count))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(categoryColor.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())

            // Exercise list (collapsible)
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(exercises, id: \.self) { exerciseName in
                        ExerciseProgressRowView(
                            exerciseName: exerciseName,
                            workouts: workouts,
                            workoutStore: workoutStore
                        )
                    }
                }
            }
        }
    }

    private var categoryIcon: String {
        switch category {
        case .push: return "arrow.up.circle.fill"
        case .pull: return "arrow.down.circle.fill"
        case .legs: return "figure.walk"
        case .core: return "circle.grid.cross.fill"
        }
    }

    private var categoryColor: Color {
        switch category {
        case .push: return .blue
        case .pull: return .green
        case .legs: return .orange
        case .core: return .purple
        }
    }
}

#Preview {
    ProgressView(mainTabSelection: .constant(2))
        .environmentObject(WorkoutStore())
        .environmentObject(NutritionStore())
        .environmentObject(ThemeManager())
}