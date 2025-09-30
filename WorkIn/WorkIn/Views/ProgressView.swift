import SwiftUI

struct ProgressView: View {
    @StateObject private var progressData = ProgressData()
    @StateObject private var workoutStore = WorkoutStore()
    @StateObject private var nutritionStore = NutritionStore()
    @State private var selectedWorkout: Workout?
    @State private var showingWorkoutDetail = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        VolumeChartView(workouts: progressData.workoutHistory)
                            .frame(height: 200)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .id(progressData.workoutHistory.count)

                        CaloriesChartView(nutritionData: nutritionStore.dailyNutrition)
                            .frame(height: 200)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .id(nutritionStore.dailyNutrition.count)
                    }

                    recentWorkoutsSection

                    exerciseProgressSection
                }
                .padding()
            }
            .navigationTitle("Progress")
            .onAppear {
                progressData.loadWorkoutHistory()
            }
            .sheet(isPresented: $showingWorkoutDetail) {
                if let workout = selectedWorkout {
                    WorkoutDetailView(workout: workout)
                }
            }
        }
    }

    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Workouts")
                .font(.headline)
                .padding(.horizontal)

            if progressData.workoutHistory.isEmpty {
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
                    ForEach(progressData.workoutHistory.prefix(5)) { workout in
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

            if !getUniqueExercises().isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(getUniqueExercises(), id: \.self) { exerciseName in
                        ExerciseProgressRowView(
                            exerciseName: exerciseName,
                            workouts: progressData.workoutHistory
                        )
                    }
                }
                .padding(.horizontal)
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

    private func getUniqueExercises() -> [String] {
        let allExercises = progressData.workoutHistory.flatMap { $0.exercises.map { $0.name } }
        return Array(Set(allExercises)).sorted()
    }
}

struct RecentWorkoutRowView: View {
    let workout: Workout
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(workout.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(formatDate(workout.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Image(systemName: "dumbbell.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("\(workout.exercises.count) exercises")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(formatDuration(workout.duration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("\(Int(getTotalVolume(workout))) lbs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if !workout.exercises.isEmpty {
                        Text(workout.exercises.map { $0.name }.joined(separator: ", "))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
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

class ProgressData: ObservableObject {
    @Published var workoutHistory: [Workout] = []

    init() {
        loadWorkoutHistory()

        // Listen for workout completion notifications
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("WorkoutCompleted"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let workout = notification.object as? Workout {
                self?.addCompletedWorkout(workout)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func loadWorkoutHistory() {
        let workoutStore = WorkoutStore()
        self.workoutHistory = workoutStore.workouts.sorted { $0.date > $1.date }
    }

    func addCompletedWorkout(_ workout: Workout) {
        workoutHistory.insert(workout, at: 0)
        workoutHistory.sort { $0.date > $1.date }
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
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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

#Preview {
    ProgressView()
}