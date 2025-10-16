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
        ExerciseTemplate(name: "Dead Bug", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),

        // Full Body / Conditioning
        ExerciseTemplate(name: "Farmer's Carries", muscleGroups: ["Forearms", "Core", "Traps"], category: .pull, equipment: .dumbbell),

        // Additional Chest Exercises - Machines
        ExerciseTemplate(name: "Chest Press Machine", muscleGroups: ["Chest", "Triceps", "Shoulders"], category: .push, equipment: .machine),
        ExerciseTemplate(name: "Incline Chest Press Machine", muscleGroups: ["Chest", "Triceps", "Shoulders"], category: .push, equipment: .machine),
        ExerciseTemplate(name: "Decline Chest Press Machine", muscleGroups: ["Chest", "Triceps"], category: .push, equipment: .machine),
        ExerciseTemplate(name: "Pec Deck Machine", muscleGroups: ["Chest"], category: .push, equipment: .machine),
        ExerciseTemplate(name: "Cable Chest Fly", muscleGroups: ["Chest"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "Low Cable Fly", muscleGroups: ["Chest"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "High Cable Fly", muscleGroups: ["Chest"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "Cable Crossover", muscleGroups: ["Chest"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "Decline Dumbbell Press", muscleGroups: ["Chest", "Triceps"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Incline Dumbbell Fly", muscleGroups: ["Chest"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Decline Dumbbell Fly", muscleGroups: ["Chest"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Svend Press", muscleGroups: ["Chest"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Diamond Push-ups", muscleGroups: ["Chest", "Triceps"], category: .push, equipment: .bodyweight),
        ExerciseTemplate(name: "Wide Push-ups", muscleGroups: ["Chest"], category: .push, equipment: .bodyweight),
        ExerciseTemplate(name: "Decline Push-ups", muscleGroups: ["Chest"], category: .push, equipment: .bodyweight),

        // Additional Back Exercises - Machines & Cables
        ExerciseTemplate(name: "Assisted Pull-up Machine", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .machine),
        ExerciseTemplate(name: "Lever High Row Machine", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .machine),
        ExerciseTemplate(name: "Chest Supported Row Machine", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .machine),
        ExerciseTemplate(name: "Hammer Strength Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .machine),
        ExerciseTemplate(name: "Pendlay Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "Yates Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "Kroc Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Meadows Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "Wide Grip Lat Pulldown", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Close Grip Lat Pulldown", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Underhand Lat Pulldown", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "V-Bar Lat Pulldown", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Straight Arm Pulldown", muscleGroups: ["Back"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Single Arm Cable Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Wide Grip Cable Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "V-Bar Cable Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Hyperextensions", muscleGroups: ["Lower Back", "Glutes", "Hamstrings"], category: .pull, equipment: .bodyweight),
        ExerciseTemplate(name: "Reverse Hyperextensions", muscleGroups: ["Lower Back", "Glutes"], category: .pull, equipment: .machine),
        ExerciseTemplate(name: "Inverted Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .bodyweight),
        ExerciseTemplate(name: "Seal Row", muscleGroups: ["Back", "Biceps"], category: .pull, equipment: .barbell),

        // Additional Leg Exercises - Machines
        ExerciseTemplate(name: "Hack Squat Machine", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Sissy Squat", muscleGroups: ["Quadriceps"], category: .legs, equipment: .bodyweight),
        ExerciseTemplate(name: "Goblet Squat", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .dumbbell),
        ExerciseTemplate(name: "Box Squat", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Pause Squat", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Safety Bar Squat", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Zercher Squat", muscleGroups: ["Quadriceps", "Glutes", "Core"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Smith Machine Squat", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Leg Extension", muscleGroups: ["Quadriceps"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Seated Leg Curl", muscleGroups: ["Hamstrings"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Lying Leg Curl", muscleGroups: ["Hamstrings"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Standing Leg Curl", muscleGroups: ["Hamstrings"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Nordic Curl", muscleGroups: ["Hamstrings"], category: .legs, equipment: .bodyweight),
        ExerciseTemplate(name: "Glute Ham Raise", muscleGroups: ["Hamstrings", "Glutes"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Hip Thrust", muscleGroups: ["Glutes", "Hamstrings"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Hip Thrust Machine", muscleGroups: ["Glutes", "Hamstrings"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Cable Pull Through", muscleGroups: ["Glutes", "Hamstrings"], category: .legs, equipment: .cable),
        ExerciseTemplate(name: "Glute Kickback Machine", muscleGroups: ["Glutes"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Cable Glute Kickback", muscleGroups: ["Glutes"], category: .legs, equipment: .cable),
        ExerciseTemplate(name: "Abductor Machine", muscleGroups: ["Abductors"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Adductor Machine", muscleGroups: ["Inner Thighs"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Walking Lunges", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .dumbbell),
        ExerciseTemplate(name: "Reverse Lunges", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .dumbbell),
        ExerciseTemplate(name: "Lateral Lunges", muscleGroups: ["Quadriceps", "Glutes", "Inner Thighs"], category: .legs, equipment: .dumbbell),
        ExerciseTemplate(name: "Curtsy Lunges", muscleGroups: ["Glutes", "Quadriceps"], category: .legs, equipment: .dumbbell),
        ExerciseTemplate(name: "Step-ups", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .dumbbell),
        ExerciseTemplate(name: "Box Step-ups", muscleGroups: ["Quadriceps", "Glutes"], category: .legs, equipment: .bodyweight),
        ExerciseTemplate(name: "Dumbbell Romanian Deadlift", muscleGroups: ["Hamstrings", "Glutes"], category: .legs, equipment: .dumbbell),
        ExerciseTemplate(name: "Single Leg Romanian Deadlift", muscleGroups: ["Hamstrings", "Glutes"], category: .legs, equipment: .dumbbell),
        ExerciseTemplate(name: "Good Mornings", muscleGroups: ["Hamstrings", "Lower Back", "Glutes"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Sumo Deadlift", muscleGroups: ["Hamstrings", "Glutes", "Inner Thighs"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Trap Bar Deadlift", muscleGroups: ["Hamstrings", "Glutes", "Back"], category: .legs, equipment: .barbell),
        ExerciseTemplate(name: "Standing Calf Raise Machine", muscleGroups: ["Calves"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Seated Calf Raise Machine", muscleGroups: ["Calves"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Leg Press Calf Raise", muscleGroups: ["Calves"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Donkey Calf Raise", muscleGroups: ["Calves"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Single Leg Calf Raise", muscleGroups: ["Calves"], category: .legs, equipment: .bodyweight),
        ExerciseTemplate(name: "Smith Machine Calf Raise", muscleGroups: ["Calves"], category: .legs, equipment: .machine),
        ExerciseTemplate(name: "Tibialis Raises", muscleGroups: ["Tibialis Anterior"], category: .legs, equipment: .bodyweight),
        ExerciseTemplate(name: "Ankle Eversion", muscleGroups: ["Fibularis"], category: .legs, equipment: .bodyweight),

        // Additional Shoulder Exercises - Machines & Cables
        ExerciseTemplate(name: "Shoulder Press Machine", muscleGroups: ["Shoulders", "Triceps"], category: .push, equipment: .machine),
        ExerciseTemplate(name: "Arnold Press", muscleGroups: ["Shoulders", "Triceps"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Landmine Press", muscleGroups: ["Shoulders", "Triceps"], category: .push, equipment: .barbell),
        ExerciseTemplate(name: "Viking Press", muscleGroups: ["Shoulders", "Triceps"], category: .push, equipment: .barbell),
        ExerciseTemplate(name: "Cable Lateral Raise", muscleGroups: ["Shoulders"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "Cable Front Raise", muscleGroups: ["Shoulders"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "Reverse Pec Deck", muscleGroups: ["Shoulders", "Upper Back"], category: .pull, equipment: .machine),
        ExerciseTemplate(name: "Cable Rear Delt Fly", muscleGroups: ["Shoulders"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Bent Over Lateral Raise", muscleGroups: ["Shoulders"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Upright Row", muscleGroups: ["Shoulders", "Traps"], category: .push, equipment: .barbell),
        ExerciseTemplate(name: "Cable Upright Row", muscleGroups: ["Shoulders", "Traps"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "Barbell Shrugs", muscleGroups: ["Traps"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "Dumbbell Shrugs", muscleGroups: ["Traps"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Cable Shrugs", muscleGroups: ["Traps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Smith Machine Shrugs", muscleGroups: ["Traps"], category: .pull, equipment: .machine),

        // Additional Arm Exercises - Machines & Cables
        ExerciseTemplate(name: "EZ Bar Curl", muscleGroups: ["Biceps"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "Cable Bicep Curl", muscleGroups: ["Biceps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "High Cable Curl", muscleGroups: ["Biceps"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Concentration Curl", muscleGroups: ["Biceps"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Incline Dumbbell Curl", muscleGroups: ["Biceps"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Spider Curl", muscleGroups: ["Biceps"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "Machine Bicep Curl", muscleGroups: ["Biceps"], category: .pull, equipment: .machine),
        ExerciseTemplate(name: "Reverse Curl", muscleGroups: ["Biceps", "Forearms"], category: .pull, equipment: .barbell),
        ExerciseTemplate(name: "Cable Hammer Curl", muscleGroups: ["Biceps", "Forearms"], category: .pull, equipment: .cable),
        ExerciseTemplate(name: "Zottman Curl", muscleGroups: ["Biceps", "Forearms"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Overhead Cable Tricep Extension", muscleGroups: ["Triceps"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "Rope Tricep Pushdown", muscleGroups: ["Triceps"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "V-Bar Tricep Pushdown", muscleGroups: ["Triceps"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "Reverse Grip Tricep Pushdown", muscleGroups: ["Triceps"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "Overhead Dumbbell Extension", muscleGroups: ["Triceps"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Skull Crushers", muscleGroups: ["Triceps"], category: .push, equipment: .barbell),
        ExerciseTemplate(name: "Dumbbell Kickback", muscleGroups: ["Triceps"], category: .push, equipment: .dumbbell),
        ExerciseTemplate(name: "Cable Kickback", muscleGroups: ["Triceps"], category: .push, equipment: .cable),
        ExerciseTemplate(name: "Machine Tricep Extension", muscleGroups: ["Triceps"], category: .push, equipment: .machine),
        ExerciseTemplate(name: "Bench Dips", muscleGroups: ["Triceps"], category: .push, equipment: .bodyweight),
        ExerciseTemplate(name: "Wrist Curl", muscleGroups: ["Forearms"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Reverse Wrist Curl", muscleGroups: ["Forearms"], category: .pull, equipment: .dumbbell),
        ExerciseTemplate(name: "Barbell Wrist Curl", muscleGroups: ["Forearms"], category: .pull, equipment: .barbell),

        // Additional Core Exercises
        ExerciseTemplate(name: "Side Plank", muscleGroups: ["Core", "Obliques"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Hollow Body Hold", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Bicycle Crunches", muscleGroups: ["Core", "Obliques"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Leg Raises", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Hanging Leg Raises", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Hanging Knee Raises", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Ab Wheel Rollout", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Cable Crunch", muscleGroups: ["Core"], category: .core, equipment: .cable),
        ExerciseTemplate(name: "Cable Woodchop", muscleGroups: ["Core", "Obliques"], category: .core, equipment: .cable),
        ExerciseTemplate(name: "Pallof Press", muscleGroups: ["Core", "Obliques"], category: .core, equipment: .cable),
        ExerciseTemplate(name: "Decline Sit-ups", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "V-ups", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Toes to Bar", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Dragon Flag", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "L-Sit", muscleGroups: ["Core"], category: .core, equipment: .bodyweight),
        ExerciseTemplate(name: "Side Bends", muscleGroups: ["Obliques"], category: .core, equipment: .dumbbell),
        ExerciseTemplate(name: "Weighted Decline Sit-ups", muscleGroups: ["Core"], category: .core, equipment: .dumbbell),
        ExerciseTemplate(name: "Machine Crunch", muscleGroups: ["Core"], category: .core, equipment: .machine)
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