import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @EnvironmentObject var profileStore: UserProfileStore
    @State private var showingExerciseSelection = false

    var body: some View {
        NavigationView {
            VStack {
                if let currentWorkout = workoutStore.currentWorkout {
                    ActiveWorkoutView(
                        workout: currentWorkout,
                        workoutStore: workoutStore,
                        showingExerciseSelection: $showingExerciseSelection,
                        bodyWeight: profileStore.profile.currentWeight
                    )
                } else {
                    WorkoutHistoryView(workouts: workoutStore.workouts, workoutStore: workoutStore, bodyWeight: profileStore.profile.currentWeight)
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Workout") {
                        startQuickWorkout()
                    }
                }
            }
            .sheet(isPresented: $showingExerciseSelection) {
                ExerciseSelectionView(
                    workoutStore: workoutStore,
                    isPresented: $showingExerciseSelection
                )
            }
        }
    }

    private func startQuickWorkout() {
        let workoutName = "Workout \(DateFormatter.shortDateFormatter.string(from: Date()))"
        workoutStore.startWorkout(name: workoutName)
        showingExerciseSelection = true
    }
}

extension DateFormatter {
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}

struct WorkoutHistoryView: View {
    let workouts: [Workout]
    @ObservedObject var workoutStore: WorkoutStore
    let bodyWeight: Double

    var body: some View {
        List {
            ForEach(workouts) { workout in
                WorkoutRowView(workout: workout, bodyWeight: bodyWeight)
            }
            .onDelete(perform: workoutStore.deleteWorkouts)
        }
        .listStyle(PlainListStyle())
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    let bodyWeight: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(alignment: .center) {
                // Duration on the left
                if workout.duration > 0 {
                    Text(formatDuration(workout.duration))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Large rank badge in the center
                if let rank = workout.getHighestRank(bodyWeight: bodyWeight) {
                    Image(rank.badgeImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .padding(.horizontal, 8)
                        .onAppear {
                            print("🏋️ WorkoutRowView: Displaying rank \(rank.badgeImageName) for workout '\(workout.name)' (bodyweight: \(bodyWeight) lbs)")
                        }
                }

                // Exercise count on the right
                Text("\(workout.exercises.count) exercises")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .onAppear {
                if workout.getHighestRank(bodyWeight: bodyWeight) == nil {
                    print("🏋️ WorkoutRowView: No rank found for workout '\(workout.name)' (bodyweight: \(bodyWeight) lbs)")
                }
            }

            if !workout.exercises.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(workout.exercises.prefix(3)) { exercise in
                            ExerciseBadge(exerciseName: exercise.name)
                        }
                        if workout.exercises.count > 3 {
                            Text("+\(workout.exercises.count - 3) more")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

struct ExerciseBadge: View {
    let exerciseName: String

    var body: some View {
        Text(exerciseName)
            .font(.caption)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
    }
}

struct WorkoutCompletion: Identifiable {
    let id = UUID()
    let workout: Workout
    let rank: StrengthRank?
    let personalRecords: [PersonalRecord]
}

struct ActiveWorkoutView: View {
    @State var workout: Workout
    @ObservedObject var workoutStore: WorkoutStore
    @Binding var showingExerciseSelection: Bool
    let bodyWeight: Double
    @State private var startTime = Date()
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var workoutCompletion: WorkoutCompletion?
    @State private var showingEmptyWorkoutAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                workoutHeader

                if workout.exercises.isEmpty {
                    emptyExercisesView
                } else {
                    exercisesSection
                }

                actionButtons
            }
            .padding()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: workoutStore.currentWorkout) { newWorkout in
            // Only sync if exercises were added/removed, not if sets were updated
            // This prevents overwriting local set changes
            if let newWorkout = newWorkout {
                if newWorkout.exercises.count != workout.exercises.count {
                    print("📝 onChange: Syncing workout due to exercise count change (\(workout.exercises.count) -> \(newWorkout.exercises.count))")
                    workout = newWorkout
                } else {
                    print("📝 onChange: Skipping sync - exercise count is same (\(workout.exercises.count))")
                }
            } else {
                print("📝 onChange: workoutStore.currentWorkout is nil")
            }
        }
        .sheet(item: $workoutCompletion) { completion in
            WorkoutCompletionSummaryView(
                completedWorkout: completion.workout,
                achievedRank: completion.rank,
                personalRecords: completion.personalRecords,
                isPresented: Binding(
                    get: { workoutCompletion != nil },
                    set: { if !$0 { workoutCompletion = nil } }
                )
            )
            .onAppear {
                print("🎉 SUCCESS: Sheet presenting completion summary for workout: \(completion.workout.name)")
                print("🎉 SUCCESS: Rank in sheet: \(completion.rank?.rawValue ?? "None")")
            }
            .onDisappear {
                // Save workout when sheet is dismissed
                workoutStore.currentWorkout = completion.workout
                workoutStore.finishCurrentWorkout()
                NotificationCenter.default.post(name: NSNotification.Name("WorkoutCompleted"), object: completion.workout)
                print("🎉 Workout saved to store after sheet dismissed")
                workoutCompletion = nil
            }
        }
        .alert("No Sets Logged", isPresented: $showingEmptyWorkoutAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please add at least one set to an exercise before finishing your workout.")
        }
    }

    private var workoutHeader: some View {
        VStack(spacing: 8) {
            Text(workout.name)
                .font(.title)
                .fontWeight(.bold)

            Text("Duration: \(formatDuration(elapsedTime))")
                .font(.title3)
                .foregroundColor(.blue)
                .fontWeight(.medium)

            Text("\(workout.exercises.count) exercises")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var emptyExercisesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No exercises added yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Tap 'Add Exercise' to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
    }

    private var exercisesSection: some View {
        VStack(spacing: 16) {
            ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                ActiveExerciseView(
                    exercise: exercise,
                    exerciseIndex: index,
                    onUpdateSets: { updatedSets in
                        updateExerciseSets(exerciseIndex: index, sets: updatedSets)
                    }
                )
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { showingExerciseSelection = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Exercise")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }

            Button(action: finishWorkout) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Finish Workout")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(startTime)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateExerciseInStore(_ updatedExercise: Exercise) {
        workoutStore.currentWorkout?.exercises = workout.exercises
    }

    private func updateExerciseSets(exerciseIndex: Int, sets: [ExerciseSet]) {
        guard exerciseIndex >= 0 && exerciseIndex < workout.exercises.count else {
            print("⚠️ updateExerciseSets: Invalid index \(exerciseIndex)")
            return
        }

        print("📝 updateExerciseSets: Updating exercise \(exerciseIndex) (\(workout.exercises[exerciseIndex].name)) with \(sets.count) sets")

        // Create a new workout to trigger SwiftUI update (structs need replacement, not mutation)
        var updatedWorkout = workout
        updatedWorkout.exercises[exerciseIndex].sets = sets
        workout = updatedWorkout
        print("📝 updateExerciseSets: Local workout now has \(workout.exercises[exerciseIndex].sets.count) sets")

        // Update workout store - need to replace the whole workout to trigger @Published
        if var currentWorkout = workoutStore.currentWorkout {
            currentWorkout.exercises[exerciseIndex].sets = sets
            workoutStore.currentWorkout = currentWorkout
            print("📝 updateExerciseSets: Store workout now has \(workoutStore.currentWorkout?.exercises[exerciseIndex].sets.count ?? 0) sets")
        }
    }

    private func finishWorkout() {
        print("🎉 finishWorkout() called - starting workout completion")

        // Check if any sets have been logged
        let totalSets = workout.exercises.reduce(0) { $0 + $1.sets.count }
        if totalSets == 0 {
            print("⚠️ No sets logged - showing alert")
            showingEmptyWorkoutAlert = true
            return
        }

        stopTimer()

        // Use the LOCAL workout variable which has the most up-to-date sets
        var finalWorkout = workout
        finalWorkout.date = Date()
        finalWorkout.duration = elapsedTime

        print("🎉 Current workout found: \(finalWorkout.name)")
        print("🎉 DEBUG: Final workout has \(finalWorkout.exercises.count) exercises")
        for (i, ex) in finalWorkout.exercises.enumerated() {
            print("🎉 DEBUG: Exercise \(i): \(ex.name) - \(ex.sets.count) sets")
            for (j, set) in ex.sets.enumerated() {
                print("🎉 DEBUG:   Set \(j): \(set.reps) reps × \(set.weight) lbs")
            }
        }

        // Detect personal records and rank
        let previousWorkouts = workoutStore.workouts
        let detectedPRs = finalWorkout.detectPersonalRecords(comparedTo: previousWorkouts)
        let detectedRank = finalWorkout.getHighestRank(bodyWeight: bodyWeight)

        print("🎉 Workout completed with \(detectedPRs.count) PRs and rank: \(detectedRank?.rawValue ?? "None") (bodyweight: \(bodyWeight) lbs)")

        // Create completion object with all data bundled together
        let completion = WorkoutCompletion(
            workout: finalWorkout,
            rank: detectedRank,
            personalRecords: detectedPRs
        )

        print("🎉 About to show completion summary - Rank: \(completion.rank?.rawValue ?? "None")")
        workoutCompletion = completion
        print("🎉 workoutCompletion set - sheet should now appear")
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

struct NewWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutName = ""
    @State private var showingTemplates = false
    @ObservedObject var workoutStore: WorkoutStore

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Start New Workout")
                        .font(.title)
                        .fontWeight(.bold)

                    TextField("Workout Name", text: $workoutName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }

                VStack(spacing: 12) {
                    Button(action: startCustomWorkout) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Start Custom Workout")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(workoutName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(workoutName.isEmpty)

                    Button(action: { showingTemplates = true }) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Choose from Templates")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingTemplates) {
                TemplateSelectionView(workoutStore: workoutStore)
            }
        }
    }

    private func startCustomWorkout() {
        workoutStore.startWorkout(name: workoutName)
        dismiss()
    }
}

struct TemplateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var workoutStore: WorkoutStore

    var body: some View {
        NavigationView {
            List(WorkoutTemplateDatabase.templates) { template in
                Button(action: {
                    workoutStore.startWorkoutFromTemplate(template)
                    dismiss()
                }) {
                    WorkoutTemplateRowView(template: template)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Workout Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Workout Completion Summary

struct WorkoutCompletionSummaryView: View {
    let completedWorkout: Workout
    let achievedRank: StrengthRank?
    let personalRecords: [PersonalRecord]
    @Binding var isPresented: Bool
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Celebration Header
                    VStack(spacing: 16) {
                        Text("🎉 Workout Complete! 🎉")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.accentColor)

                        Text(completedWorkout.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.primaryTextColor)

                        Text(formatDuration(completedWorkout.duration))
                            .font(.headline)
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .padding()
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(16)

                    // Rank Achievement
                    if let rank = achievedRank {
                        VStack(spacing: 12) {
                            Text("Strength Achievement")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryTextColor)

                            HStack(spacing: 16) {
                                Image(rank.badgeImageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(rank.rawValue)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(themeManager.accentColor)

                                    Text(getRankMessage(for: rank))
                                        .font(.subheadline)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        .padding()
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 2)
                        )
                        .onAppear {
                            print("🏆 SUMMARY: Displaying rank: \(rank.rawValue) \(rank.symbol)")
                        }
                    } else {
                        Text("🏆 No rank achieved (add weight exercises to earn a rank!)")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .padding()
                            .onAppear {
                                print("🏆 SUMMARY: No rank to display - achievedRank is nil")
                            }
                    }

                    // Personal Records
                    if !personalRecords.isEmpty {
                        VStack(spacing: 12) {
                            HStack {
                                Text("🚀 New Personal Records!")
                                    .font(.headline)
                                    .foregroundColor(themeManager.accentColor)
                                Spacer()
                            }

                            ForEach(personalRecords.indices, id: \.self) { index in
                                let pr = personalRecords[index]
                                PersonalRecordRowView(personalRecord: pr)
                            }
                        }
                        .padding()
                        .background(themeManager.cardBackgroundColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.4), lineWidth: 2)
                        )
                    }

                    // Workout Stats
                    VStack(spacing: 12) {
                        Text("Workout Stats")
                            .font(.headline)
                            .foregroundColor(themeManager.primaryTextColor)

                        HStack(spacing: 20) {
                            StatItemView(
                                icon: "dumbbell.fill",
                                label: "Exercises",
                                value: "\(completedWorkout.exercises.count)"
                            )

                            StatItemView(
                                icon: "clock.fill",
                                label: "Duration",
                                value: formatDurationShort(completedWorkout.duration)
                            )

                            StatItemView(
                                icon: "flame.fill",
                                label: "Sets",
                                value: "\(completedWorkout.exercises.map { $0.sets.count }.reduce(0, +))"
                            )
                        }
                    }
                    .padding()
                    .background(themeManager.secondaryBackgroundColor)
                    .cornerRadius(12)

                    // Workout Details
                    VStack(spacing: 12) {
                        HStack {
                            Text("Workout Details")
                                .font(.headline)
                                .foregroundColor(themeManager.primaryTextColor)
                            Spacer()
                        }

                        ForEach(completedWorkout.exercises) { exercise in
                            ExerciseSummaryCard(exercise: exercise)
                        }
                    }
                    .padding()
                    .background(themeManager.cardBackgroundColor)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(themeManager.backgroundColor)
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
    }

    private func getRankMessage(for rank: StrengthRank) -> String {
        switch rank {
        case .bronze:
            return "Great start on your strength journey!"
        case .silver:
            return "You're building solid foundations!"
        case .gold:
            return "Impressive strength development!"
        case .platinum:
            return "You're among the strong ones!"
        case .diamond:
            return "Outstanding strength achievement!"
        case .arnold:
            return "Arnold-level strength! Legendary!"
        case .hulk:
            return "Hulk smash! Incredible power!"
        case .superman:
            return "Superman strength! You're unstoppable!"
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }

    private func formatDurationShort(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)m"
    }
}

struct ExerciseSummaryCard: View {
    let exercise: Exercise
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Exercise header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.primaryTextColor)

                    Text(exercise.muscleGroups.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }

                Spacer()

                Text("\(exercise.sets.count) sets")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }

            // Sets list
            VStack(spacing: 4) {
                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                    HStack(spacing: 8) {
                        Text("Set \(index + 1)")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .frame(width: 50, alignment: .leading)

                        Text("\(set.reps) reps × \(Int(set.weight)) lbs")
                            .font(.caption)
                            .foregroundColor(themeManager.primaryTextColor)

                        Spacer()

                        Text("\(Int(Double(set.reps) * set.weight)) lbs")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeManager.secondaryBackgroundColor.opacity(0.5))
                    .cornerRadius(6)
                }
            }

            // Total volume for this exercise
            HStack {
                Spacer()
                Text("Total Volume: \(calculateTotalVolume()) lbs")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.accentColor)
            }
        }
        .padding(12)
        .background(themeManager.secondaryBackgroundColor)
        .cornerRadius(8)
    }

    private func calculateTotalVolume() -> Int {
        exercise.sets.reduce(0) { total, set in
            total + Int(Double(set.reps) * set.weight)
        }
    }
}

struct PersonalRecordRowView: View {
    let personalRecord: PersonalRecord
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(personalRecord.exerciseName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primaryTextColor)

                HStack(spacing: 8) {
                    Text("\(Int(personalRecord.previousMax)) lbs")
                        .foregroundColor(themeManager.secondaryTextColor)

                    Image(systemName: "arrow.right")
                        .foregroundColor(Color.green)

                    Text("\(Int(personalRecord.newMax)) lbs")
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                }
                .font(.caption)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(Int(personalRecord.improvement)) lbs")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.green)

                Text("+\(String(format: "%.1f", personalRecord.improvementPercentage))%")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatItemView: View {
    let icon: String
    let label: String
    let value: String
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeManager.accentColor)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryTextColor)

            Text(label)
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WorkoutView()
        .environmentObject(WorkoutStore())
}