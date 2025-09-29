import Foundation

struct WorkoutTemplate {
    let name: String
    let category: String
    let exercises: [ExerciseTemplate]
    let description: String
}

class WorkoutTemplates: ObservableObject {
    static let shared = WorkoutTemplates()

    let templates: [WorkoutTemplate] = [
        WorkoutTemplate(
            name: "Push Day (Beginner)",
            category: "Push",
            exercises: [
                ExerciseTemplate(name: "Push-ups", muscleGroups: ["Chest", "Triceps", "Shoulders"], equipment: "Bodyweight", category: .push),
                ExerciseTemplate(name: "Dumbbell Shoulder Press", muscleGroups: ["Shoulders", "Triceps"], equipment: "Dumbbells", category: .push),
                ExerciseTemplate(name: "Tricep Dips", muscleGroups: ["Triceps", "Chest"], equipment: "Bodyweight", category: .push),
                ExerciseTemplate(name: "Lateral Raises", muscleGroups: ["Shoulders"], equipment: "Dumbbells", category: .push)
            ],
            description: "A beginner-friendly push workout focusing on chest, shoulders, and triceps."
        ),

        WorkoutTemplate(
            name: "Pull Day (Beginner)",
            category: "Pull",
            exercises: [
                ExerciseTemplate(name: "Lat Pulldowns", muscleGroups: ["Lats", "Biceps", "Rhomboids"], equipment: "Cable", category: .pull),
                ExerciseTemplate(name: "Seated Cable Rows", muscleGroups: ["Lats", "Rhomboids", "Biceps"], equipment: "Cable", category: .pull),
                ExerciseTemplate(name: "Bicep Curls", muscleGroups: ["Biceps"], equipment: "Dumbbells", category: .pull),
                ExerciseTemplate(name: "Face Pulls", muscleGroups: ["Rear Delts", "Rhomboids"], equipment: "Cable", category: .pull)
            ],
            description: "A beginner-friendly pull workout targeting back and biceps."
        ),

        WorkoutTemplate(
            name: "Leg Day (Beginner)",
            category: "Legs",
            exercises: [
                ExerciseTemplate(name: "Squats", muscleGroups: ["Quadriceps", "Glutes", "Hamstrings"], equipment: "Barbell", category: .legs),
                ExerciseTemplate(name: "Leg Press", muscleGroups: ["Quadriceps", "Glutes"], equipment: "Machine", category: .legs),
                ExerciseTemplate(name: "Leg Curls", muscleGroups: ["Hamstrings"], equipment: "Machine", category: .legs),
                ExerciseTemplate(name: "Calf Raises", muscleGroups: ["Calves"], equipment: "Dumbbells", category: .legs)
            ],
            description: "A comprehensive leg workout for beginners."
        ),

        WorkoutTemplate(
            name: "Push Day (Advanced)",
            category: "Push",
            exercises: [
                ExerciseTemplate(name: "Bench Press", muscleGroups: ["Chest", "Triceps", "Shoulders"], equipment: "Barbell", category: .push),
                ExerciseTemplate(name: "Incline Bench Press", muscleGroups: ["Upper Chest", "Triceps", "Shoulders"], equipment: "Barbell", category: .push),
                ExerciseTemplate(name: "Overhead Press", muscleGroups: ["Shoulders", "Triceps"], equipment: "Barbell", category: .push),
                ExerciseTemplate(name: "Lateral Raises", muscleGroups: ["Shoulders"], equipment: "Dumbbells", category: .push),
                ExerciseTemplate(name: "Close-Grip Bench Press", muscleGroups: ["Triceps", "Chest"], equipment: "Barbell", category: .push),
                ExerciseTemplate(name: "Tricep Pushdowns", muscleGroups: ["Triceps"], equipment: "Cable", category: .push)
            ],
            description: "An advanced push workout with compound and isolation movements."
        ),

        WorkoutTemplate(
            name: "Pull Day (Advanced)",
            category: "Pull",
            exercises: [
                ExerciseTemplate(name: "Pull-ups", muscleGroups: ["Lats", "Biceps", "Rhomboids"], equipment: "Bodyweight", category: .pull),
                ExerciseTemplate(name: "Bent-Over Rows", muscleGroups: ["Lats", "Rhomboids", "Biceps"], equipment: "Barbell", category: .pull),
                ExerciseTemplate(name: "Lat Pulldowns", muscleGroups: ["Lats", "Biceps", "Rhomboids"], equipment: "Cable", category: .pull),
                ExerciseTemplate(name: "Dumbbell Rows", muscleGroups: ["Lats", "Rhomboids", "Biceps"], equipment: "Dumbbells", category: .pull),
                ExerciseTemplate(name: "Face Pulls", muscleGroups: ["Rear Delts", "Rhomboids"], equipment: "Cable", category: .pull),
                ExerciseTemplate(name: "Preacher Curls", muscleGroups: ["Biceps"], equipment: "Barbell", category: .pull)
            ],
            description: "An advanced pull workout targeting all back muscles and biceps."
        ),

        WorkoutTemplate(
            name: "Leg Day (Advanced)",
            category: "Legs",
            exercises: [
                ExerciseTemplate(name: "Squats", muscleGroups: ["Quadriceps", "Glutes", "Hamstrings"], equipment: "Barbell", category: .legs),
                ExerciseTemplate(name: "Deadlifts", muscleGroups: ["Hamstrings", "Glutes", "Lower Back"], equipment: "Barbell", category: .legs),
                ExerciseTemplate(name: "Romanian Deadlifts", muscleGroups: ["Hamstrings", "Glutes"], equipment: "Barbell", category: .legs),
                ExerciseTemplate(name: "Bulgarian Split Squats", muscleGroups: ["Quadriceps", "Glutes"], equipment: "Dumbbells", category: .legs),
                ExerciseTemplate(name: "Hip Thrusts", muscleGroups: ["Glutes", "Hamstrings"], equipment: "Barbell", category: .legs),
                ExerciseTemplate(name: "Calf Raises", muscleGroups: ["Calves"], equipment: "Dumbbells", category: .legs)
            ],
            description: "An advanced leg workout with compound movements and unilateral exercises."
        ),

        WorkoutTemplate(
            name: "Full Body (Beginner)",
            category: "Full Body",
            exercises: [
                ExerciseTemplate(name: "Squats", muscleGroups: ["Quadriceps", "Glutes", "Hamstrings"], equipment: "Barbell", category: .legs),
                ExerciseTemplate(name: "Push-ups", muscleGroups: ["Chest", "Triceps", "Shoulders"], equipment: "Bodyweight", category: .push),
                ExerciseTemplate(name: "Bent-Over Rows", muscleGroups: ["Lats", "Rhomboids", "Biceps"], equipment: "Barbell", category: .pull),
                ExerciseTemplate(name: "Overhead Press", muscleGroups: ["Shoulders", "Triceps"], equipment: "Barbell", category: .push),
                ExerciseTemplate(name: "Planks", muscleGroups: ["Core", "Abs"], equipment: "Bodyweight", category: .core)
            ],
            description: "A full body workout perfect for beginners or those with limited time."
        ),

        WorkoutTemplate(
            name: "Core & Abs",
            category: "Core",
            exercises: [
                ExerciseTemplate(name: "Planks", muscleGroups: ["Core", "Abs"], equipment: "Bodyweight", category: .core),
                ExerciseTemplate(name: "Russian Twists", muscleGroups: ["Abs", "Obliques"], equipment: "Bodyweight", category: .core),
                ExerciseTemplate(name: "Leg Raises", muscleGroups: ["Lower Abs"], equipment: "Bodyweight", category: .core),
                ExerciseTemplate(name: "Bicycle Crunches", muscleGroups: ["Abs", "Obliques"], equipment: "Bodyweight", category: .core),
                ExerciseTemplate(name: "Mountain Climbers", muscleGroups: ["Core", "Abs"], equipment: "Bodyweight", category: .core),
                ExerciseTemplate(name: "Side Planks", muscleGroups: ["Obliques", "Core"], equipment: "Bodyweight", category: .core)
            ],
            description: "A focused core and abs workout to strengthen your midsection."
        )
    ]

    func getTemplatesByCategory(_ category: String) -> [WorkoutTemplate] {
        if category == "All" {
            return templates
        }
        return templates.filter { $0.category == category }
    }

    func getAllCategories() -> [String] {
        let categories = Set(templates.map { $0.category })
        return ["All"] + Array(categories).sorted()
    }
}