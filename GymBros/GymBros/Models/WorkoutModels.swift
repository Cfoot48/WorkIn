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
    var muscleGroups: [String]
    var equipment: String
    var sets: [ExerciseSet]

    init(name: String, muscleGroups: [String], equipment: String, sets: [ExerciseSet] = []) {
        self.id = UUID()
        self.name = name
        self.muscleGroups = muscleGroups
        self.equipment = equipment
        self.sets = sets
    }
}

struct ExerciseSet: Identifiable, Codable, Equatable {
    let id: UUID
    var reps: Int
    var weight: Double
    var restTime: TimeInterval
    var completed: Bool

    init(reps: Int, weight: Double, restTime: TimeInterval = 60, completed: Bool = false) {
        self.id = UUID()
        self.reps = reps
        self.weight = weight
        self.restTime = restTime
        self.completed = completed
    }
}