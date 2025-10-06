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
    @State private var showingConfirmation = false

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
                    }
                }

                Spacer()

                Button(action: { showingConfirmation = true }) {
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
        .alert("Log Meal", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Log") {
                logMealFromTemplate()
            }
        } message: {
            Text("Log all foods from '\(template.name)' to today's nutrition?")
        }
    }

    private func logMealFromTemplate() {
        for food in template.foods {
            nutritionStore.addFoodEntry(food)
        }
    }
}

// MARK: - Workout Generator View
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

    var body: some View {
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
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Generating...")
                                    .padding(.leading, 8)
                            } else {
                                Label("Generate Workout Plan", systemImage: "sparkles")
                            }
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
        }
    }

    private func generateWorkoutPlan() {
        isGenerating = true
        errorMessage = nil

        Task {
            do {
                let plan = try await AIAssistantService.shared.generateWorkoutPlan(
                    userProfile: profileStore.profile,
                    workoutHistory: workoutStore.workouts,
                    preferences: preferences.isEmpty ? nil : preferences
                )

                await MainActor.run {
                    // Convert AI plan to workout template
                    let exercises = plan.exercises.map { aiExercise in
                        Exercise(
                            name: aiExercise.name,
                            sets: (0..<aiExercise.sets).map { _ in
                                ExerciseSet(
                                    reps: aiExercise.reps,
                                    weight: aiExercise.weight,
                                    restTime: aiExercise.restTime
                                )
                            },
                            muscleGroups: aiExercise.muscleGroups,
                            equipment: aiExercise.equipment
                        )
                    }

                    let template = AIWorkoutTemplate(
                        name: plan.name,
                        exercises: exercises
                    )

                    templateStore.addWorkoutTemplate(template)
                    isGenerating = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isGenerating = false
                }
            }
        }
    }
}

// MARK: - Meal Generator View
struct MealGeneratorView: View {
    @EnvironmentObject var profileStore: UserProfileStore
    @EnvironmentObject var templateStore: TemplateStore
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var preferences = ""
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showingError = false

    var body: some View {
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
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Generating...")
                                    .padding(.leading, 8)
                            } else {
                                Label("Generate Meal Plan", systemImage: "sparkles")
                            }
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
        }
    }

    private func generateMealPlan() {
        isGenerating = true
        errorMessage = nil

        Task {
            do {
                let plan = try await AIAssistantService.shared.generateMealPlan(
                    userProfile: profileStore.profile,
                    preferences: preferences.isEmpty ? nil : preferences
                )

                await MainActor.run {
                    // Convert AI plan to meal template
                    let foods = plan.meals.flatMap { meal in
                        meal.foods.map { aiFood in
                            FoodEntry(
                                name: aiFood.name,
                                calories: aiFood.calories,
                                protein: aiFood.protein,
                                carbs: aiFood.carbs,
                                fat: aiFood.fat
                            )
                        }
                    }

                    let template = MealTemplate(
                        name: plan.name,
                        foods: foods
                    )

                    templateStore.addMealTemplate(template)
                    isGenerating = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isGenerating = false
                }
            }
        }
    }
}

// Type aliases for easier referencing
typealias AIWorkoutGeneratorView = WorkoutGeneratorView
typealias AIMealGeneratorView = MealGeneratorView

#Preview {
    AIAssistantView()
        .environmentObject(UserProfileStore())
        .environmentObject(WorkoutStore())
        .environmentObject(NutritionStore())
        .environmentObject(TemplateStore())
        .environmentObject(ThemeManager())
}
