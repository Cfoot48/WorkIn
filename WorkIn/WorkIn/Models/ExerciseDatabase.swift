import Foundation

struct ExerciseDatabase {
    static let exercises: [ExerciseTemplate] = [
        // Chest Exercises
        ExerciseTemplate(name: "Bench Press", muscleGroups: ["Chest", "Triceps", "Shoulders"], category: .push, equipment: .barbell),
        ExerciseTemplate(name: "Incline Bench Press", muscleGroups: ["Chest", "Triceps", "Shoulders"], category: .push, equipment: .barbell),
        ExerciseTemplate(name: "Decline Bench Press", muscleGroups: ["Chest", "Triceps"], category: .push, equipment: .barbell),
        ExerciseTemplate(name: "Dumbbell Press", muscleGroups: ["Chest", "Triceps", "Shoulders"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Incline Dumbbell Press", muscleGroups: ["Chest", "Triceps", "Shoulders"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Chest Fly", muscleGroups: ["Chest"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Push-ups", muscleGroups: ["Chest", "Triceps", "Shoulders"], category: .push, equipment: .bodyweight),
        ExerciseTemplate(name: "Dips", muscleGroups: ["Chest", "Triceps"], category: .push, equipment: .bodyweight),

        // Back Exercises
        ExerciseTemplate(name: "Deadlift", muscleGroups: ["Back", "Glutes", "Hamstrings"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "Pull-ups", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .bodyweight),
        ExerciseTemplate(name: "Chin-ups", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .bodyweight),
        ExerciseTemplate(name: "Bent Over Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "T-Bar Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "Dumbbell Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Lat Pulldown", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Seated Cable Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .cable),

        // Leg Exercises
        ExerciseTemplate(name: "Squats", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Front Squats", muscleGroups: ["Quadriceps", "Core"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Bulgarian Split Squats", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .dumbbell),
        ExerciseTemplate(name: "Lunges", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .dumbbell),
        ExerciseTemplate(name: "Leg Press", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Romanian Deadlift", muscleGroups: ["Hamstrings", "Glutes"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Leg Curls", muscleGroups: ["Hamstrings"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Calf Raises", muscleGroups: ["Calves"], category: .legs, equipment: .dumbbell),

        // Shoulder Exercises
        ExerciseTemplate(name: "Overhead Press", muscleGroups: ["Shoulders", "Triceps"], category: .push, equipment: .barbell),
        ExerciseTemplate(name: "Dumbbell Shoulder Press", muscleGroups: ["Shoulders", "Triceps"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Lateral Raises", muscleGroups: ["Shoulders"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Front Raises", muscleGroups: ["Shoulders"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Rear Delt Fly", muscleGroups: ["Shoulders"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Face Pulls", muscleGroups: ["Shoulders", "Upper Back"], category: .pull, equipment: .cable),

        // Arm Exercises
        ExerciseTemplate(name: "Bicep Curls", muscleGroups: ["Biceps"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Hammer Curls", muscleGroups: ["Biceps", "Forearms"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Preacher Curls", muscleGroups: ["Biceps"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "Tricep Dips", muscleGroups: ["Triceps"], category: .push, equipment: .bodyweight),
        ExerciseTemplate(name: "Close Grip Bench Press", muscleGroups: ["Triceps", "Chest"], category: .push, equipment: .barbell),
        ExerciseTemplate(name: "Tricep Extensions", muscleGroups: ["Triceps"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Cable Tricep Pushdowns", muscleGroups: ["Triceps"], category: .push, equipment: .cable),

        // Core Exercises
        ExerciseTemplate(name: "Plank", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Crunches", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Russian Twists", muscleGroups: ["Core", "Obliques"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Mountain Climbers", muscleGroups: ["Core", "Cardio"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Dead Bug", muscleGroups: ["Core"], category: .core, equipment: .bodyweight)
    ]

    static func searchExercises(_ searchText: String) -> [ExerciseTemplate] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(searchText) ||
            exercise.muscleGroups.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    static func exercisesByCategory(_ category: ExerciseCategory) -> [ExerciseTemplate] {
        return exercises.filter { $0.category == category }
    }
}

struct ExerciseTemplate: Identifiable, Codable {
    let id = UUID()
    let name: String
    let muscleGroups: [String]
    let category: ExerciseCategory
    let equipment: Equipment

    func toExercise() -> Exercise {
        return Exercise(name: name, sets: [], muscleGroups: muscleGroups, equipment: equipment.rawValue)
    }
}

enum ExerciseCategory: String, CaseIterable, Codable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case core = "Core"
}

enum Equipment: String, CaseIterable, Codable {
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case cable = "Cable"
    case machine = "Machine"
    case bodyweight = "Bodyweight"
}