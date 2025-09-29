import Foundation

struct WorkoutTemplate: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let category: String
    let exercises: [String] // Exercise names that will be looked up
    let estimatedDuration: TimeInterval

    func createWorkout() -> Workout {
        let workoutExercises = exercises.compactMap { exerciseName in
            ExerciseDatabase.exercises.first(where: { $0.name == exerciseName })?.toExercise()
        }
        return Workout(name: name, exercises: workoutExercises)
    }
}

struct WorkoutTemplateDatabase {
    static let templates: [WorkoutTemplate] = [
        // Push Day Templates
        WorkoutTemplate(
            name: "Push Day - Beginner",
            description: "Chest, shoulders, and triceps workout for beginners",
            category: "Push",
            exercises: [
                "Bench Press",
                "Dumbbell Shoulder Press",
                "Incline Dumbbell Press",
                "Lateral Raises",
                "Tricep Extensions",
                "Push-ups"
            ],
            estimatedDuration: 3600 // 60 minutes
        ),

        WorkoutTemplate(
            name: "Push Day - Advanced",
            description: "Intense chest, shoulders, and triceps workout",
            category: "Push",
            exercises: [
                "Bench Press",
                "Incline Bench Press",
                "Dumbbell Press",
                "Overhead Press",
                "Lateral Raises",
                "Front Raises",
                "Close Grip Bench Press",
                "Cable Tricep Pushdowns",
                "Dips"
            ],
            estimatedDuration: 5400 // 90 minutes
        ),

        // Pull Day Templates
        WorkoutTemplate(
            name: "Pull Day - Beginner",
            description: "Back and biceps workout for beginners",
            category: "Pull",
            exercises: [
                "Bent Over Row",
                "Lat Pulldown",
                "Seated Cable Row",
                "Dumbbell Row",
                "Bicep Curls",
                "Hammer Curls"
            ],
            estimatedDuration: 3600 // 60 minutes
        ),

        WorkoutTemplate(
            name: "Pull Day - Advanced",
            description: "Intense back and biceps workout",
            category: "Pull",
            exercises: [
                "Deadlift",
                "Pull-ups",
                "Bent Over Row",
                "T-Bar Row",
                "Lat Pulldown",
                "Face Pulls",
                "Bicep Curls",
                "Hammer Curls",
                "Preacher Curls"
            ],
            estimatedDuration: 5400 // 90 minutes
        ),

        // Leg Day Templates
        WorkoutTemplate(
            name: "Leg Day - Beginner",
            description: "Complete leg workout for beginners",
            category: "Legs",
            exercises: [
                "Squats",
                "Romanian Deadlift",
                "Lunges",
                "Leg Curls",
                "Calf Raises"
            ],
            estimatedDuration: 3600 // 60 minutes
        ),

        WorkoutTemplate(
            name: "Leg Day - Advanced",
            description: "Intense leg workout for experienced lifters",
            category: "Legs",
            exercises: [
                "Squats",
                "Front Squats",
                "Romanian Deadlift",
                "Bulgarian Split Squats",
                "Leg Press",
                "Leg Curls",
                "Calf Raises"
            ],
            estimatedDuration: 5400 // 90 minutes
        ),

        // Full Body Templates
        WorkoutTemplate(
            name: "Full Body - Beginner",
            description: "Complete full body workout",
            category: "Full Body",
            exercises: [
                "Squats",
                "Bench Press",
                "Bent Over Row",
                "Dumbbell Shoulder Press",
                "Bicep Curls",
                "Tricep Extensions",
                "Plank"
            ],
            estimatedDuration: 4200 // 70 minutes
        )
    ]

    static func templatesByCategory(_ category: String) -> [WorkoutTemplate] {
        return templates.filter { $0.category == category }
    }

    static func searchTemplates(_ searchText: String) -> [WorkoutTemplate] {
        if searchText.isEmpty {
            return templates
        }
        return templates.filter { template in
            template.name.localizedCaseInsensitiveContains(searchText) ||
            template.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}