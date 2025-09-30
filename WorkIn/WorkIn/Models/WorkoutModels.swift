import Foundation

struct Workout: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var exercises: [Exercise]
    var date: Date
    var duration: TimeInterval

    init(name: String, exercises: [Exercise] = [], date: Date = Date(), duration: TimeInterval = 0) {
        self.id = UUID()
        self.name = name
        self.exercises = exercises
        self.date = date
        self.duration = duration
    }
}

struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var sets: [ExerciseSet]
    var muscleGroups: [String]
    var equipment: String

    init(id: UUID = UUID(), name: String, sets: [ExerciseSet] = [], muscleGroups: [String] = [], equipment: String = "") {
        self.id = id
        self.name = name
        self.sets = sets
        self.muscleGroups = muscleGroups
        self.equipment = equipment
    }
}

struct ExerciseSet: Identifiable, Codable, Equatable {
    let id: UUID
    var reps: Int
    var weight: Double
    var restTime: Double
    var completed: Bool

    init(id: UUID = UUID(), reps: Int, weight: Double, restTime: Double = 60, completed: Bool = false) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.restTime = restTime
        self.completed = completed
    }
}

class WorkoutStore: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var currentWorkout: Workout?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firestoreManager = FirestoreManager()

    init() {
        setupFirestoreListeners()
    }

    // MARK: - Firebase Integration
    private func setupFirestoreListeners() {
        firestoreManager.listenToWorkouts { [weak self] (workouts: [Workout]) in
            DispatchQueue.main.async {
                self?.workouts = workouts
                self?.isLoading = false
            }
        }
    }

    func loadWorkouts() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let fetchedWorkouts = try await firestoreManager.fetchWorkouts()
            await MainActor.run {
                self.workouts = fetchedWorkouts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                // Fallback to sample data if user is offline or there's an error
                self.loadSampleData()
            }
        }
    }

    func saveWorkout(_ workout: Workout) async {
        do {
            try await firestoreManager.saveWorkout(workout)
            await MainActor.run {
                // Update local array if not already present
                if !workouts.contains(where: { $0.id == workout.id }) {
                    workouts.insert(workout, at: 0)
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to save workout: \(error.localizedDescription)"
                // Still add to local array as fallback
                if !workouts.contains(where: { $0.id == workout.id }) {
                    workouts.insert(workout, at: 0)
                }
            }
        }
    }

    func deleteWorkout(_ workout: Workout) async {
        await MainActor.run {
            // Optimistically remove from UI
            workouts.removeAll { $0.id == workout.id }
        }

        do {
            try await firestoreManager.deleteWorkout(workout.id.uuidString)
        } catch {
            await MainActor.run {
                // Restore workout if delete failed
                workouts.append(workout)
                errorMessage = "Failed to delete workout: \(error.localizedDescription)"
            }
        }
    }

    func deleteWorkouts(at indexSet: IndexSet) {
        let workoutsToDelete = indexSet.map { workouts[$0] }

        // Remove from local array immediately
        workouts.remove(atOffsets: indexSet)

        // Delete from Firebase
        Task {
            for workout in workoutsToDelete {
                do {
                    try await firestoreManager.deleteWorkout(workout.id.uuidString)
                } catch {
                    await MainActor.run {
                        errorMessage = "Failed to delete some workouts: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    // MARK: - Local Workout Management
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)

        // Also save to Firebase
        Task {
            await saveWorkout(workout)
        }
    }

    func startWorkout(name: String) {
        currentWorkout = Workout(name: name)
    }

    func startWorkoutFromTemplate(_ template: WorkoutTemplate) {
        currentWorkout = template.createWorkout()
    }

    func addExerciseToCurrentWorkout(_ exercise: Exercise) {
        guard var workout = currentWorkout else { return }
        workout.exercises.append(exercise)
        currentWorkout = workout // This triggers @Published update
    }

    func finishCurrentWorkout() {
        if let workout = currentWorkout {
            var finishedWorkout = workout
            finishedWorkout.date = Date()

            // Add to local array
            workouts.insert(finishedWorkout, at: 0)
            currentWorkout = nil

            // Save to Firebase
            Task {
                await saveWorkout(finishedWorkout)
            }
        }
    }

    // MARK: - Sample Data (Fallback)
    private func loadSampleData() {
        // Only load sample data if workouts array is empty
        guard workouts.isEmpty else { return }

        let sampleExercises = [
            Exercise(name: "Bench Press", sets: [
                ExerciseSet(reps: 10, weight: 135),
                ExerciseSet(reps: 8, weight: 155),
                ExerciseSet(reps: 6, weight: 175)
            ], muscleGroups: ["Chest", "Triceps"]),
            Exercise(name: "Squats", sets: [
                ExerciseSet(reps: 12, weight: 185),
                ExerciseSet(reps: 10, weight: 205),
                ExerciseSet(reps: 8, weight: 225)
            ], muscleGroups: ["Quadriceps", "Glutes"])
        ]

        let sampleWorkout = Workout(
            name: "Push Day",
            exercises: sampleExercises,
            date: Date().addingTimeInterval(-86400),
            duration: 3600
        )

        workouts.append(sampleWorkout)
    }

    deinit {
        firestoreManager.removeAllListeners()
    }
}