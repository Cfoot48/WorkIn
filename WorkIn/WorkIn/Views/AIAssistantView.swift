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
                                            .foregroundColor(.cyan)
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
                        .background(Color.cyan)
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
            .fullScreenCover(isPresented: $isGenerating) {
                LoadingView(message: "Generating your meal plan...")
                    .interactiveDismissDisabled()
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
                    Color.cyan.opacity(0.3),
                    Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.4),
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
                        .shadow(color: .cyan, radius: 20)
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
                    .shadow(color: .cyan, radius: 10)
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
