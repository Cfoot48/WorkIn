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

    init() {
        loadSampleData()
    }

    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
    }

    func deleteWorkout(_ workout: Workout) {
        workouts.removeAll { $0.id == workout.id }
    }

    func deleteWorkouts(at indexSet: IndexSet) {
        workouts.remove(atOffsets: indexSet)
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
            workouts.append(finishedWorkout)
            currentWorkout = nil
        }
    }

    private func loadSampleData() {
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
}