import SwiftUI

struct WorkoutView: View {
    @StateObject private var workoutData = WorkoutData()
    @State private var showingExerciseSelection = false
    @State private var showingSetLogging = false
    @State private var selectedExercise: ExerciseTemplate?
    @State private var activeWorkout: Workout?
    @State private var workoutTimer: Timer?
    @State private var elapsedTime: TimeInterval = 0

    var body: some View {
        NavigationView {
            VStack {
                if let workout = activeWorkout {
                    activeWorkoutView(workout)
                } else {
                    workoutHistoryView
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if activeWorkout == nil {
                        Button("New Workout") {
                            showingExerciseSelection = true
                        }
                    } else {
                        Button("Finish") {
                            finishWorkout()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingExerciseSelection) {
                ExerciseSelectionView { exercises in
                    startWorkout(with: exercises)
                }
            }
            .sheet(item: $selectedExercise) { exercise in
                SetLoggingView(exercise: exercise) { sets in
                    addExerciseToWorkout(exercise: exercise, sets: sets)
                }
            }
        }
    }

    private func activeWorkoutView(_ workout: Workout) -> some View {
        VStack(spacing: 20) {
            // Timer
            VStack {
                Text("Workout Timer")
                    .font(.headline)
                Text(formatTime(elapsedTime))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            // Current exercises
            List {
                ForEach(workout.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name)
                            .font(.headline)
                        Text(exercise.muscleGroups.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(exercise.sets) { set in
                            HStack {
                                Text("Set \(exercise.sets.firstIndex(where: { $0.id == set.id })! + 1):")
                                Text("\(set.reps) reps @ \(Int(set.weight))lbs")
                                Spacer()
                                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(set.completed ? .green : .gray)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Button("Add Exercise") {
                showingExerciseSelection = true
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var workoutHistoryView: some View {
        VStack {
            if workoutData.workouts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No workouts yet")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Tap 'New Workout' to get started!")
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                List {
                    ForEach(workoutData.workouts.sorted(by: { $0.date > $1.date })) { workout in
                        WorkoutRowView(workout: workout)
                    }
                    .onDelete(perform: deleteWorkouts)
                }
            }
        }
    }

    private func startWorkout(with exercises: [ExerciseTemplate]) {
        let workoutExercises = exercises.map { template in
            Exercise(
                name: template.name,
                muscleGroups: template.muscleGroups,
                equipment: template.equipment,
                sets: []
            )
        }

        activeWorkout = Workout(
            name: "Workout \(Date().formatted(date: .abbreviated, time: .shortened))",
            exercises: workoutExercises
        )
        elapsedTime = 0
        showingExerciseSelection = false
    }

    private func addExerciseToWorkout(exercise: ExerciseTemplate, sets: [ExerciseSet]) {
        guard var workout = activeWorkout else { return }

        if let index = workout.exercises.firstIndex(where: { $0.name == exercise.name }) {
            workout.exercises[index].sets = sets
        } else {
            let newExercise = Exercise(
                name: exercise.name,
                muscleGroups: exercise.muscleGroups,
                equipment: exercise.equipment,
                sets: sets
            )
            workout.exercises.append(newExercise)
        }

        activeWorkout = workout
        selectedExercise = nil
    }

    private func finishWorkout() {
        guard var workout = activeWorkout else { return }

        workout.duration = elapsedTime
        workoutData.addWorkout(workout)
        activeWorkout = nil
        stopTimer()
        elapsedTime = 0
    }

    private func deleteWorkouts(offsets: IndexSet) {
        let sortedWorkouts = workoutData.workouts.sorted(by: { $0.date > $1.date })
        for index in offsets {
            if let workoutIndex = workoutData.workouts.firstIndex(where: { $0.id == sortedWorkouts[index].id }) {
                workoutData.workouts.remove(at: workoutIndex)
            }
        }
    }

    private func startTimer() {
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    private func stopTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60
        let seconds = Int(time) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct WorkoutRowView: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.name)
                    .font(.headline)
                Spacer()
                Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text("\(workout.exercises.count) exercises")
                .font(.caption)
                .foregroundColor(.secondary)

            if workout.duration > 0 {
                Text("Duration: \(formatDuration(workout.duration))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
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
}

class WorkoutData: ObservableObject {
    @Published var workouts: [Workout] = []

    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
    }
}

#Preview {
    WorkoutView()
}