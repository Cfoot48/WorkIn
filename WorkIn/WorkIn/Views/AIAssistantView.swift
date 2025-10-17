import SwiftUI

struct AIAssistantView: View {
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var templateStore: TemplateStore
    @EnvironmentObject var themeManager: ThemeManager

    @State private var selectedTab = 0
    @State private var showingWorkoutGenerator = false
    @State private var showingMealGenerator = false
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Assistant Type", selection: $selectedTab) {
                    Text("Workouts").tag(0)
                    Text("Meals").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedTab == 0 {
                    WorkoutTemplatesView(
                        showingGenerator: $showingWorkoutGenerator
                    )
                } else {
                    MealTemplatesView(
                        showingGenerator: $showingMealGenerator
                    )
                }
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .background(themeManager.backgroundColor)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingWorkoutGenerator) {
                WorkoutGeneratorView()
            }
            .sheet(isPresented: $showingMealGenerator) {
                MealGeneratorView()
            }
            .sheet(isPresented: $showingSettings) {
                AISettingsView()
            }
        }
    }
}

// MARK: - Workout Templates View
struct WorkoutTemplatesView: View {
    @EnvironmentObject var templateStore: TemplateStore
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var showingGenerator: Bool

    var body: some View {
        VStack {
            if templateStore.workoutTemplates.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 60))
                        .foregroundColor(themeManager.secondaryTextColor)

                    Text("No Workout Templates")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)

                    Text("Tap the button below to generate a personalized workout plan using AI")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button(action: { showingGenerator = true }) {
                        Label("Generate Workout Plan", systemImage: "sparkles")
                            .padding()
                            .background(themeManager.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(templateStore.workoutTemplates) { template in
                        WorkoutTemplateRow(template: template)
                    }
                    .onDelete(perform: deleteTemplates)
                }
                .listStyle(PlainListStyle())
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingGenerator = true }) {
                    Image(systemName: "sparkles")
                }
            }
        }
    }

    private func deleteTemplates(at offsets: IndexSet) {
        for index in offsets {
            templateStore.deleteWorkoutTemplate(templateStore.workoutTemplates[index])
        }
    }
}

struct WorkoutTemplateRow: View {
    let template: AIWorkoutTemplate
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)

                    Text("\(template.exercises.count) exercises")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }

                Spacer()

                Button(action: { showingConfirmation = true }) {
                    Label("Start Workout", systemImage: "play.fill")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(themeManager.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            // Exercise preview
            VStack(alignment: .leading, spacing: 4) {
                ForEach(template.exercises.prefix(3)) { exercise in
                    HStack {
                        Text("• \(exercise.name)")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                        Spacer()
                        Text("\(exercise.sets.count) sets")
                            .font(.caption2)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                }
                if template.exercises.count > 3 {
                    Text("+ \(template.exercises.count - 3) more...")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .italic()
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .alert("Start Workout", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Start") {
                startWorkoutFromTemplate()
            }
        } message: {
            Text("Start a new workout from '\(template.name)'?")
        }
    }

    private func startWorkoutFromTemplate() {
        let workout = template.createWorkout()
        workoutStore.currentWorkout = workout
    }
}

// MARK: - Meal Templates View
struct MealTemplatesView: View {
    @EnvironmentObject var templateStore: TemplateStore
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var showingGenerator: Bool

    var body: some View {
        VStack {
            if templateStore.mealTemplates.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 60))
                        .foregroundColor(themeManager.secondaryTextColor)

                    Text("No Meal Templates")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)

                    Text("Tap the button below to generate a personalized meal plan using AI")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button(action: { showingGenerator = true }) {
                        Label("Generate Meal Plan", systemImage: "sparkles")
                            .padding()
                            .background(themeManager.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(templateStore.mealTemplates) { template in
                        MealTemplateRow(template: template)
                    }
                    .onDelete(perform: deleteTemplates)
                }
                .listStyle(PlainListStyle())
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingGenerator = true }) {
                    Image(systemName: "sparkles")
                }
            }
        }
    }

    private func deleteTemplates(at offsets: IndexSet) {
        for index in offsets {
            templateStore.deleteMealTemplate(templateStore.mealTemplates[index])
        }
    }
}

struct MealTemplateRow: View {
    let template: MealTemplate
    @EnvironmentObject var nutritionStore: NutritionStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingServingsPicker = false
    @State private var selectedServings: Double = 1.0

    var totalCalories: Double {
        template.foods.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        template.foods.reduce(0) { $0 + $1.protein }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)

                    HStack(spacing: 12) {
                        Text("\(Int(totalCalories)) cal")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                        Text("\(Int(totalProtein))g protein")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                        if let servings = template.servings, servings > 1 {
                            Text("(\(servings) servings)")
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    }
                }

                Spacer()

                Button(action: { showingServingsPicker = true }) {
                    Label("Log Meal", systemImage: "plus.circle.fill")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(themeManager.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            // Food preview
            VStack(alignment: .leading, spacing: 4) {
                ForEach(template.foods.prefix(3)) { food in
                    Text("• \(food.name)")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                if template.foods.count > 3 {
                    Text("+ \(template.foods.count - 3) more...")
                        .font(.caption2)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .italic()
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingServingsPicker) {
            ServingsPickerView(
                mealName: template.name,
                totalServings: template.servings ?? 1,
                selectedServings: $selectedServings,
                onConfirm: {
                    logMealFromTemplate(servings: selectedServings)
                    showingServingsPicker = false
                }
            )
            .environmentObject(themeManager)
        }
    }

    private func logMealFromTemplate(servings: Double) {
        let totalServings = Double(template.servings ?? 1)
        let multiplier = servings / totalServings

        for food in template.foods {
            let adjustedFood = FoodEntry(
                name: food.name,
                calories: food.calories * multiplier,
                protein: food.protein * multiplier,
                carbs: food.carbs * multiplier,
                fat: food.fat * multiplier,
                mealType: food.mealType
            )
            nutritionStore.addFoodEntry(adjustedFood)
        }
    }
}

// MARK: - Servings Picker View
struct ServingsPickerView: View {
    let mealName: String
    let totalServings: Int
    @Binding var selectedServings: Double
    let onConfirm: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("How many servings?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                Text(mealName)
                    .font(.headline)
                    .foregroundColor(themeManager.secondaryTextColor)

                if totalServings > 1 {
                    Text("This recipe makes \(totalServings) servings")
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryTextColor)
                }

                // Servings picker
                VStack(spacing: 16) {
                    Text("\(selectedServings, specifier: "%.1f") serving\(selectedServings == 1.0 ? "" : "s")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.accentColor)

                    Slider(value: $selectedServings, in: 0.5...Double(max(totalServings, 4)), step: 0.5)
                        .accentColor(themeManager.accentColor)
                        .padding(.horizontal)
                }
                .padding()

                Spacer()

                Button(action: onConfirm) {
                    Text("Log Meal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.accentColor)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Workout Generator View
@MainActor
struct WorkoutGeneratorView: View {
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var templateStore: TemplateStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var preferences = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var generatedPlan: AIWorkoutPlan?
    @State private var showingResult = false

    var body: some View {
        let _ = print("🎬 WorkoutGenerator body rendering - isGenerating: \(isGenerating)")
        NavigationView {
            Form {
                Section(header: Text("Your Profile")) {
                    HStack {
                        Text("Goal")
                        Spacer()
                        Text(profileStore.profile.goalType.rawValue)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    HStack {
                        Text("Weekly Workouts")
                        Spacer()
                        Text("\(profileStore.profile.weeklyWorkoutGoal)")
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                }

                Section(header: Text("Preferences (Optional)")) {
                    TextEditor(text: $preferences)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    Text("Example: Focus on upper body, avoid squats, include cardio")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }

                Section {
                    Button(action: generateWorkoutPlan) {
                        HStack {
                            Spacer()
                            Label("Generate Workout Plan", systemImage: "sparkles")
                            Spacer()
                        }
                    }
                    .disabled(isGenerating)
                }
            }
            .navigationTitle("AI Workout Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
            .sheet(isPresented: $showingResult) {
                if let plan = generatedPlan {
                    WorkoutPlanResultView(
                        plan: plan,
                        onSave: {
                            saveWorkoutPlan(plan)
                            showingResult = false
                            dismiss()
                        },
                        onStartWorkout: {
                            startWorkoutFromPlan(plan)
                            showingResult = false
                            dismiss()
                        },
                        onCancel: {
                            showingResult = false
                        }
                    )
                    .environmentObject(themeManager)
                }
            }
            .fullScreenCover(isPresented: $isGenerating) {
                LoadingView(message: "Generating your workout...")
                    .interactiveDismissDisabled()
            }
        }
    }

    private func saveWorkoutPlan(_ plan: AIWorkoutPlan) {
        print("💾 Saving workout plan: \(plan.name)")

        // Extract exercise names from AI plan
        let exerciseNames = plan.exercises.map { $0.name }

        // Add to WorkoutTemplateDatabase
        WorkoutTemplateDatabase.addAITemplate(name: plan.name, exercises: exerciseNames)

        print("💾 Template added to WorkoutTemplateDatabase. Total templates: \(WorkoutTemplateDatabase.templates.count)")
    }

    private func startWorkoutFromPlan(_ plan: AIWorkoutPlan) {
        print("🏋️ Starting workout from plan: \(plan.name)")

        // Start the workout with the name
        workoutStore.startWorkout(name: plan.name)

        // Add each exercise to the workout
        for aiExercise in plan.exercises {
            let exercise = Exercise(
                name: aiExercise.name,
                sets: (0..<aiExercise.sets).map { _ in
                    ExerciseSet(
                        reps: aiExercise.reps,
                        weight: aiExercise.weight ?? 0,
                        restTime: aiExercise.restTime ?? 60
                    )
                },
                muscleGroups: aiExercise.muscleGroups ?? ["General"],
                equipment: aiExercise.equipment ?? "Barbell"
            )
            workoutStore.addExerciseToCurrentWorkout(exercise)
        }

        print("🏋️ Workout started with \(plan.exercises.count) exercises")
    }

    private func generateWorkoutPlan() {
        print("🎬 Starting workout generation...")
        isGenerating = true
        print("🎬 isGenerating set to: \(isGenerating)")
        errorMessage = nil

        Task {
            do {
                print("🎬 Calling AI service...")
                let plan = try await AIAssistantService.shared.generateWorkoutPlan(
                    userProfile: profileStore.profile,
                    workoutHistory: workoutStore.workouts,
                    preferences: preferences.isEmpty ? nil : preferences
                )

                await MainActor.run {
                    print("🎬 AI service completed successfully")
                    generatedPlan = plan
                    isGenerating = false
                    print("🎬 isGenerating set to: \(isGenerating)")
                    showingResult = true
                }
            } catch {
                await MainActor.run {
                    print("🎬 AI service error: \(error)")
                    errorMessage = error.localizedDescription
                    showingError = true
                    isGenerating = false
                    print("🎬 isGenerating set to: \(isGenerating)")
                }
            }
        }
    }
}

// MARK: - Workout Plan Result View
struct WorkoutPlanResultView: View {
    let plan: AIWorkoutPlan
    let onSave: () -> Void
    let onStartWorkout: () -> Void
    let onCancel: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Plan Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(plan.name)
                                .font(.title)
                                .fontWeight(.bold)

                            if let description = plan.description {
                                Text(description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()

                        // Exercises List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercises (\(plan.exercises.count))")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(Array(plan.exercises.enumerated()), id: \.offset) { index, exercise in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(exercise.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)

                                    HStack(spacing: 16) {
                                        Label("\(exercise.sets) sets", systemImage: "list.number")
                                        Label("\(exercise.reps) reps", systemImage: "repeat")
                                        if let weight = exercise.weight, weight > 0 {
                                            Label("\(Int(weight)) lbs", systemImage: "scalemass")
                                        }
                                        if let rest = exercise.restTime {
                                            Label("\(Int(rest))s rest", systemImage: "timer")
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                    if let muscles = exercise.muscleGroups, !muscles.isEmpty {
                                        Text(muscles.joined(separator: ", "))
                                            .font(.caption2)
                                            .foregroundColor(DesignSystem.Colors.primary)
                                    }
                                }
                                .padding()
                                .background(themeManager.secondaryBackgroundColor)
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 20)
                    }
                }

                // Bottom action buttons
                VStack(spacing: 12) {
                    Button(action: onStartWorkout) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Workout Now")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(DesignSystem.Colors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Button(action: onSave) {
                        HStack {
                            Image(systemName: "bookmark.fill")
                            Text("Save for Later")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(themeManager.backgroundColor)
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("AI Workout Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }
}

// MARK: - Meal Generator View
@MainActor
struct MealGeneratorView: View {
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var templateStore: TemplateStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var preferences = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var generatedPlan: AIMealPlan?
    @State private var showingResult = false

    var body: some View {
        let _ = print("🍽️ MealGenerator body rendering - isGenerating: \(isGenerating)")
        NavigationView {
            Form {
                Section(header: Text("Your Profile")) {
                    HStack {
                        Text("Goal")
                        Spacer()
                        Text(profileStore.profile.goalType.rawValue)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    HStack {
                        Text("Daily Calories")
                        Spacer()
                        Text("\(profileStore.profile.dailyCalories)")
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    HStack {
                        Text("Daily Protein")
                        Spacer()
                        Text("\(profileStore.profile.dailyProtein)g")
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                }

                Section(header: Text("Preferences (Optional)")) {
                    TextEditor(text: $preferences)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    Text("Example: Vegetarian, no dairy, high protein breakfast")
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }

                Section {
                    Button(action: generateMealPlan) {
                        HStack {
                            Spacer()
                            Label("Generate Meal Plan", systemImage: "sparkles")
                            Spacer()
                        }
                    }
                    .disabled(isGenerating)
                }
            }
            .navigationTitle("AI Meal Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
            .sheet(isPresented: $showingResult) {
                if let plan = generatedPlan {
                    MealPlanResultView(
                        plan: plan,
                        onSave: { selectedMeals in
                            saveSelectedRecipes(selectedMeals)
                            showingResult = false
                            dismiss()
                        },
                        onCancel: {
                            showingResult = false
                        }
                    )
                    .environmentObject(themeManager)
                }
            }
            .fullScreenCover(isPresented: $isGenerating) {
                LoadingView(message: "Generating your meal plan...")
                    .interactiveDismissDisabled()
            }
        }
    }

    private func saveSelectedRecipes(_ selectedMeals: [AIMeal]) {
        print("💾 Saving \(selectedMeals.count) selected recipes")

        for meal in selectedMeals {
            // Convert each recipe to a FoodEntry for the meal template
            let foodEntry = FoodEntry(
                name: meal.name,
                calories: meal.totalCalories,
                protein: meal.totalProtein,
                carbs: meal.totalCarbs,
                fat: meal.totalFat
            )

            let template = MealTemplate(
                name: meal.name,
                foods: [foodEntry],
                ingredients: meal.ingredients,
                instructions: meal.instructions,
                servings: meal.servings
            )

            templateStore.addMealTemplate(template)
        }

        print("💾 Saved \(selectedMeals.count) recipes as meal templates")
    }

    private func generateMealPlan() {
        print("🍽️ Starting meal generation...")
        isGenerating = true
        errorMessage = nil

        Task {
            do {
                print("🍽️ Calling AI service...")
                let plan = try await AIAssistantService.shared.generateMealPlan(
                    userProfile: profileStore.profile,
                    preferences: preferences.isEmpty ? nil : preferences
                )

                await MainActor.run {
                    print("🍽️ AI service completed successfully")
                    generatedPlan = plan
                    isGenerating = false
                    showingResult = true
                }
            } catch {
                await MainActor.run {
                    print("🍽️ AI service error: \(error)")
                    errorMessage = error.localizedDescription
                    showingError = true
                    isGenerating = false
                }
            }
        }
    }
}

// MARK: - Meal Plan Result View
struct MealPlanResultView: View {
    let plan: AIMealPlan
    let onSave: ([AIMeal]) -> Void
    let onCancel: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    @State private var selectedMeals: Set<String> = []
    @State private var expandedRecipes: Set<String> = []

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Plan Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI-Generated Recipes")
                                .font(.title)
                                .fontWeight(.bold)

                            Text("Select the recipes you want to save as meal presets")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()

                        // Recipes List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recipes (\(plan.meals.count))")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(plan.meals, id: \.name) { meal in
                                RecipeCard(
                                    meal: meal,
                                    isSelected: selectedMeals.contains(meal.name),
                                    isExpanded: expandedRecipes.contains(meal.name),
                                    onToggleSelection: {
                                        if selectedMeals.contains(meal.name) {
                                            selectedMeals.remove(meal.name)
                                        } else {
                                            selectedMeals.insert(meal.name)
                                        }
                                    },
                                    onToggleExpand: {
                                        if expandedRecipes.contains(meal.name) {
                                            expandedRecipes.remove(meal.name)
                                        } else {
                                            expandedRecipes.insert(meal.name)
                                        }
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 20)
                    }
                }

                // Bottom action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        let selected = plan.meals.filter { selectedMeals.contains($0.name) }
                        onSave(selected)
                    }) {
                        HStack {
                            Image(systemName: "bookmark.fill")
                            Text("Save Selected Recipes (\(selectedMeals.count))")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedMeals.isEmpty ? Color.gray : DesignSystem.Colors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(selectedMeals.isEmpty)

                    Button(action: {
                        selectedMeals = Set(plan.meals.map { $0.name })
                    }) {
                        Text("Select All")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.secondaryBackgroundColor)
                            .foregroundColor(themeManager.accentColor)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(themeManager.backgroundColor)
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("AI Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }
}

// MARK: - Recipe Card
struct RecipeCard: View {
    let meal: AIMeal
    let isSelected: Bool
    let isExpanded: Bool
    let onToggleSelection: () -> Void
    let onToggleExpand: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with checkbox and name
            HStack(alignment: .top, spacing: 12) {
                Button(action: onToggleSelection) {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.title2)
                        .foregroundColor(isSelected ? DesignSystem.Colors.primary : .gray)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(meal.name)
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)

                    Text(meal.description)
                        .font(.subheadline)
                        .foregroundColor(themeManager.secondaryTextColor)
                        .lineLimit(isExpanded ? nil : 2)

                    // Nutrition summary
                    HStack(spacing: 16) {
                        Label("\(Int(meal.totalCalories)) cal", systemImage: "flame.fill")
                        Label("\(Int(meal.totalProtein))g protein", systemImage: "heart.fill")
                        Label("\(meal.servings) serving\(meal.servings > 1 ? "s" : "")", systemImage: "person.fill")
                    }
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.primary)
                }

                Spacer()

                Button(action: onToggleExpand) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }

            // Expanded details
            if isExpanded {
                Divider()

                // Ingredients
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryTextColor)

                    ForEach(meal.ingredients, id: \.self) { ingredient in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(themeManager.secondaryTextColor)
                            Text(ingredient)
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    }
                }

                Divider()

                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryTextColor)

                    ForEach(Array(meal.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.secondaryTextColor)
                            Text(instruction)
                                .font(.caption)
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                    }
                }

                Divider()

                // Complete nutrition info
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nutrition Information")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryTextColor)

                    HStack(spacing: 20) {
                        RecipeNutritionBadge(value: Int(meal.totalCalories), label: "cal", color: .orange)
                        RecipeNutritionBadge(value: Int(meal.totalProtein), label: "P", color: .red)
                        RecipeNutritionBadge(value: Int(meal.totalCarbs), label: "C", color: .blue)
                        RecipeNutritionBadge(value: Int(meal.totalFat), label: "F", color: .green)
                    }
                }
            }
        }
        .padding()
        .background(isSelected ? themeManager.accentColor.opacity(0.1) : themeManager.secondaryBackgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Recipe Nutrition Badge
struct RecipeNutritionBadge: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// Type aliases for easier referencing
typealias AIWorkoutGeneratorView = WorkoutGeneratorView
typealias AIMealGeneratorView = MealGeneratorView

// MARK: - Loading View
struct LoadingView: View {
    let message: String
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.3

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    DesignSystem.Colors.primary.opacity(0.3),
                    Color(red: 1.0, green: 0.5, blue: 0.2).opacity(0.4),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(rotation))

            // Animated circles
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200 + CGFloat(index * 100), height: 200 + CGFloat(index * 100))
                    .blur(radius: 30)
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation * Double(index + 1)))
            }

            VStack(spacing: 50) {
                // Animated AI sparkles icon
                ZStack {
                    ForEach(0..<8) { index in
                        Circle()
                            .fill(Color.white.opacity(opacity))
                            .frame(width: 8, height: 8)
                            .offset(x: cos(Double(index) * .pi / 4) * 40, y: sin(Double(index) * .pi / 4) * 40)
                            .blur(radius: 2)
                    }

                    Image(systemName: "sparkles")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .shadow(color: DesignSystem.Colors.primary, radius: 20)
                        .rotationEffect(.degrees(rotation))
                }

                // Spinner
                SwiftUI.ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2.5)
                    .shadow(color: .white.opacity(0.5), radius: 10)

                // Text with animated gradient
                Text(message)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: DesignSystem.Colors.primary, radius: 10)
                    .padding(.horizontal, 40)
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }

            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.3
            }

            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    AIAssistantView()
        .environmentObject(UserProfileStore())
        .environmentObject(WorkoutStore())
        .environmentObject(NutritionStore())
        .environmentObject(TemplateStore())
        .environmentObject(ThemeManager())
}
