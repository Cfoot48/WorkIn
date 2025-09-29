import Foundation

enum ExerciseCategory: String, CaseIterable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case core = "Core"
    case cardio = "Cardio"
}

struct ExerciseTemplate: Identifiable {
    let id = UUID()
    let name: String
    let muscleGroups: [String]
    let equipment: String
    let category: ExerciseCategory
}

class ExerciseDatabase: ObservableObject {
    static let shared = ExerciseDatabase()

    let exercises: [ExerciseTemplate] = [
        // Push Exercises
        ExerciseTemplate(name: "Push-ups", muscleGroups: ["Chest", "Triceps", "Shoulders"], equipment: "Bodyweight", category: .push),
        ExerciseTemplate(name: "Bench Press", muscleGroups: ["Chest", "Triceps", "Shoulders"], equipment: "Barbell", category: .push),
        ExerciseTemplate(name: "Incline Bench Press", muscleGroups: ["Upper Chest", "Triceps", "Shoulders"], equipment: "Barbell", category: .push),
        ExerciseTemplate(name: "Dumbbell Press", muscleGroups: ["Chest", "Triceps", "Shoulders"], equipment: "Dumbbells", category: .push),
        ExerciseTemplate(name: "Overhead Press", muscleGroups: ["Shoulders", "Triceps"], equipment: "Barbell", category: .push),
        ExerciseTemplate(name: "Dumbbell Shoulder Press", muscleGroups: ["Shoulders", "Triceps"], equipment: "Dumbbells", category: .push),
        ExerciseTemplate(name: "Lateral Raises", muscleGroups: ["Shoulders"], equipment: "Dumbbells", category: .push),
        ExerciseTemplate(name: "Tricep Dips", muscleGroups: ["Triceps", "Chest"], equipment: "Bodyweight", category: .push),
        ExerciseTemplate(name: "Tricep Pushdowns", muscleGroups: ["Triceps"], equipment: "Cable", category: .push),
        ExerciseTemplate(name: "Close-Grip Bench Press", muscleGroups: ["Triceps", "Chest"], equipment: "Barbell", category: .push),

        // Pull Exercises
        ExerciseTemplate(name: "Pull-ups", muscleGroups: ["Lats", "Biceps", "Rhomboids"], equipment: "Bodyweight", category: .pull),
        ExerciseTemplate(name: "Chin-ups", muscleGroups: ["Lats", "Biceps"], equipment: "Bodyweight", category: .pull),
        ExerciseTemplate(name: "Lat Pulldowns", muscleGroups: ["Lats", "Biceps", "Rhomboids"], equipment: "Cable", category: .pull),
        ExerciseTemplate(name: "Seated Cable Rows", muscleGroups: ["Lats", "Rhomboids", "Biceps"], equipment: "Cable", category: .pull),
        ExerciseTemplate(name: "Bent-Over Rows", muscleGroups: ["Lats", "Rhomboids", "Biceps"], equipment: "Barbell", category: .pull),
        ExerciseTemplate(name: "Dumbbell Rows", muscleGroups: ["Lats", "Rhomboids", "Biceps"], equipment: "Dumbbells", category: .pull),
        ExerciseTemplate(name: "Face Pulls", muscleGroups: ["Rear Delts", "Rhomboids"], equipment: "Cable", category: .pull),
        ExerciseTemplate(name: "Bicep Curls", muscleGroups: ["Biceps"], equipment: "Dumbbells", category: .pull),
        ExerciseTemplate(name: "Hammer Curls", muscleGroups: ["Biceps", "Forearms"], equipment: "Dumbbells", category: .pull),
        ExerciseTemplate(name: "Preacher Curls", muscleGroups: ["Biceps"], equipment: "Barbell", category: .pull),

        // Leg Exercises
        ExerciseTemplate(name: "Squats", muscleGroups: ["Quadriceps", "Glutes", "Hamstrings"], equipment: "Barbell", category: .legs),
        ExerciseTemplate(name: "Deadlifts", muscleGroups: ["Hamstrings", "Glutes", "Lower Back"], equipment: "Barbell", category: .legs),
        ExerciseTemplate(name: "Romanian Deadlifts", muscleGroups: ["Hamstrings", "Glutes"], equipment: "Barbell", category: .legs),
        ExerciseTemplate(name: "Leg Press", muscleGroups: ["Quadriceps", "Glutes"], equipment: "Machine", category: .legs),
        ExerciseTemplate(name: "Lunges", muscleGroups: ["Quadriceps", "Glutes", "Hamstrings"], equipment: "Dumbbells", category: .legs),
        ExerciseTemplate(name: "Bulgarian Split Squats", muscleGroups: ["Quadriceps", "Glutes"], equipment: "Dumbbells", category: .legs),
        ExerciseTemplate(name: "Leg Curls", muscleGroups: ["Hamstrings"], equipment: "Machine", category: .legs),
        ExerciseTemplate(name: "Leg Extensions", muscleGroups: ["Quadriceps"], equipment: "Machine", category: .legs),
        ExerciseTemplate(name: "Calf Raises", muscleGroups: ["Calves"], equipment: "Dumbbells", category: .legs),
        ExerciseTemplate(name: "Hip Thrusts", muscleGroups: ["Glutes", "Hamstrings"], equipment: "Barbell", category: .legs),

        // Core Exercises
        ExerciseTemplate(name: "Planks", muscleGroups: ["Core", "Abs"], equipment: "Bodyweight", category: .core),
        ExerciseTemplate(name: "Crunches", muscleGroups: ["Abs"], equipment: "Bodyweight", category: .core),
        ExerciseTemplate(name: "Russian Twists", muscleGroups: ["Abs", "Obliques"], equipment: "Bodyweight", category: .core),
        ExerciseTemplate(name: "Leg Raises", muscleGroups: ["Lower Abs"], equipment: "Bodyweight", category: .core),
        ExerciseTemplate(name: "Mountain Climbers", muscleGroups: ["Core", "Abs"], equipment: "Bodyweight", category: .core),
        ExerciseTemplate(name: "Dead Bug", muscleGroups: ["Core", "Abs"], equipment: "Bodyweight", category: .core),
        ExerciseTemplate(name: "Bicycle Crunches", muscleGroups: ["Abs", "Obliques"], equipment: "Bodyweight", category: .core),
        ExerciseTemplate(name: "Side Planks", muscleGroups: ["Obliques", "Core"], equipment: "Bodyweight", category: .core),

        // Cardio
        ExerciseTemplate(name: "Running", muscleGroups: ["Legs", "Cardiovascular"], equipment: "None", category: .cardio),
        ExerciseTemplate(name: "Cycling", muscleGroups: ["Legs", "Cardiovascular"], equipment: "Bike", category: .cardio),
        ExerciseTemplate(name: "Rowing", muscleGroups: ["Back", "Legs", "Cardiovascular"], equipment: "Rowing Machine", category: .cardio),
        ExerciseTemplate(name: "Elliptical", muscleGroups: ["Full Body", "Cardiovascular"], equipment: "Elliptical Machine", category: .cardio)
    ]

    func searchExercises(query: String, category: ExerciseCategory? = nil) -> [ExerciseTemplate] {
        var filtered = exercises

        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }

        if !query.isEmpty {
            filtered = filtered.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(query) ||
                exercise.muscleGroups.contains { $0.localizedCaseInsensitiveContains(query) }
            }
        }

        return filtered
    }
}