import Foundation

struct Workout: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var exercises: [Exercise]
    var date: Date
    var duration: TimeInterval
    var bodyWeight: Double? // Bodyweight at time of workout

    init(name: String, exercises: [Exercise] = [], date: Date = Date(), duration: TimeInterval = 0, bodyWeight: Double? = nil) {
        self.id = UUID()
        self.name = name
        self.exercises = exercises
        self.date = date
        self.duration = duration
        self.bodyWeight = bodyWeight
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
        print("🔥 WorkoutStore: Initializing...")
        // Delay Firebase setup to ensure user is authenticated
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.setupFirestoreListeners()
        }
    }

    private func testRankingSystem() {
        print("🏋️ Testing ranking system...")

        // Create a test workout with known values
        let testExercises = [
            Exercise(name: "Bench Press", sets: [
                ExerciseSet(reps: 6, weight: 225) // 225/181 = 1.24 ratio -> Novice
            ], muscleGroups: ["Chest"]),
            Exercise(name: "Squats", sets: [
                ExerciseSet(reps: 8, weight: 315) // 315/181 = 1.74 ratio -> Advanced
            ], muscleGroups: ["Legs"]),
            Exercise(name: "Deadlift", sets: [
                ExerciseSet(reps: 1, weight: 455) // 455/181 = 2.51 ratio -> Elite
            ], muscleGroups: ["Back"])
        ]

        let testWorkout = Workout(
            name: "Test Workout",
            exercises: testExercises,
            date: Date(),
            duration: 3600
        )

        let rank = testWorkout.getHighestRank()
        print("🏋️ Test workout rank: \(rank?.rawValue ?? "No rank") \(rank?.symbol ?? "")")
    }

    // MARK: - Firebase Integration
    private func setupFirestoreListeners() {
        print("🔥 WorkoutStore: Setting up Firestore listeners...")
        firestoreManager.listenToWorkouts { [weak self] (workouts: [Workout]) in
            print("🔥 WorkoutStore: Received \(workouts.count) workouts from Firestore")
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
        print("🔥 WorkoutStore: Attempting to save workout '\(workout.name)'")
        do {
            try await firestoreManager.saveWorkout(workout)
            print("🔥 WorkoutStore: Successfully saved workout '\(workout.name)' to Firestore")
            await MainActor.run {
                // Update local array if not already present
                if !workouts.contains(where: { $0.id == workout.id }) {
                    workouts.insert(workout, at: 0)
                }
            }
        } catch {
            print("🔥 WorkoutStore: Failed to save workout '\(workout.name)': \(error.localizedDescription)")
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
        print("🔥 WorkoutStore: Finishing current workout...")
        if let workout = currentWorkout {
            var finishedWorkout = workout
            finishedWorkout.date = Date()
            print("🔥 WorkoutStore: Finished workout '\(finishedWorkout.name)' with \(finishedWorkout.exercises.count) exercises")

            // Debug: Print detailed exercise and set information
            for (index, exercise) in finishedWorkout.exercises.enumerated() {
                print("🔥 WorkoutStore: Exercise \(index + 1): '\(exercise.name)' has \(exercise.sets.count) sets")
                for (setIndex, set) in exercise.sets.enumerated() {
                    print("🔥 WorkoutStore:   Set \(setIndex + 1): \(set.reps) reps × \(set.weight) lbs (completed: \(set.completed))")
                }
            }

            // Add to local array
            workouts.insert(finishedWorkout, at: 0)
            currentWorkout = nil

            // Save to Firebase
            Task {
                await saveWorkout(finishedWorkout)
            }
        } else {
            print("🔥 WorkoutStore: No current workout to finish")
        }
    }

    // MARK: - Sample Data (Fallback)
    private func loadSampleData() {
        // TEMPORARILY: Always load sample data to test rankings
        // guard workouts.isEmpty else { return }
        print("🏋️ Loading sample data with rankings...")

        let sampleExercises = [
            Exercise(name: "Bench Press", sets: [
                ExerciseSet(reps: 10, weight: 185),
                ExerciseSet(reps: 8, weight: 205),
                ExerciseSet(reps: 6, weight: 225)
            ], muscleGroups: ["Chest", "Triceps"]),
            Exercise(name: "Squats", sets: [
                ExerciseSet(reps: 12, weight: 225),
                ExerciseSet(reps: 10, weight: 275),
                ExerciseSet(reps: 8, weight: 315)
            ], muscleGroups: ["Quadriceps", "Glutes"]),
            Exercise(name: "Deadlift", sets: [
                ExerciseSet(reps: 5, weight: 365),
                ExerciseSet(reps: 3, weight: 405),
                ExerciseSet(reps: 1, weight: 455)
            ], muscleGroups: ["Back", "Glutes", "Hamstrings"])
        ]

        let sampleWorkout = Workout(
            name: "Heavy Compound Day",
            exercises: sampleExercises,
            date: Date().addingTimeInterval(-86400),
            duration: 3600
        )

        // Add a second sample workout with lower weights
        let lightExercises = [
            Exercise(name: "Bench Press", sets: [
                ExerciseSet(reps: 12, weight: 135),
                ExerciseSet(reps: 10, weight: 155),
                ExerciseSet(reps: 8, weight: 175)
            ], muscleGroups: ["Chest", "Triceps"]),
            Exercise(name: "Bicep Curls", sets: [
                ExerciseSet(reps: 12, weight: 85),
                ExerciseSet(reps: 10, weight: 90),
                ExerciseSet(reps: 8, weight: 95)
            ], muscleGroups: ["Biceps"])
        ]

        let lightWorkout = Workout(
            name: "Light Upper Body",
            exercises: lightExercises,
            date: Date().addingTimeInterval(-172800), // 2 days ago
            duration: 2400
        )

        workouts.append(sampleWorkout)
        workouts.append(lightWorkout)
    }

    deinit {
        firestoreManager.removeAllListeners()
    }
}

// MARK: - Strength Ranking System

enum StrengthRank: String, CaseIterable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    case diamond = "Diamond"
    case arnold = "Arnold"
    case hulk = "Hulk"
    case superman = "Superman"

    var badgeImageName: String {
        switch self {
        case .bronze: return "badge_bronze"
        case .silver: return "badge_silver"
        case .gold: return "badge_gold"
        case .platinum: return "badge_platinum"
        case .diamond: return "badge_diamond"
        case .arnold: return "badge_arnold"
        case .hulk: return "badge_hulk"
        case .superman: return "badge_superman"
        }
    }

    // Fallback emoji for compatibility
    var symbol: String {
        switch self {
        case .bronze: return "🥉"
        case .silver: return "🥈"
        case .gold: return "🥇"
        case .platinum: return "💿"
        case .diamond: return "💎"
        case .arnold: return "🏋️"
        case .hulk: return "💪"
        case .superman: return "🦸"
        }
    }

    var color: String {
        switch self {
        case .bronze: return "brown"
        case .silver: return "gray"
        case .gold: return "orange"
        case .platinum: return "teal"
        case .diamond: return "blue"
        case .arnold: return "purple"
        case .hulk: return "green"
        case .superman: return "red"
        }
    }
}

struct StrengthStandards {
    // Bodyweight multipliers for different exercises (based on powerlifting standards)
    // These are approximate standards used in strength training communities

    static func getRank(exerciseName: String, weight: Double, bodyWeight: Double) -> StrengthRank {
        let ratio = weight / bodyWeight

        // Normalize exercise name for matching
        let normalizedName = exerciseName.lowercased()

        // Squats and variants
        if normalizedName.contains("squat") || normalizedName.contains("front squat") || normalizedName.contains("back squat") {
            return getSquatRank(ratio: ratio)
        }
        // Bench press and variants
        else if normalizedName.contains("bench") || normalizedName.contains("chest press") {
            return getBenchRank(ratio: ratio)
        }
        // Deadlifts and variants
        else if normalizedName.contains("deadlift") || normalizedName.contains("romanian deadlift") || normalizedName.contains("rdl") {
            return getDeadliftRank(ratio: ratio)
        }
        // Overhead/shoulder pressing
        else if normalizedName.contains("overhead press") || normalizedName.contains("shoulder press") ||
                normalizedName.contains("military press") || normalizedName.contains("push press") ||
                normalizedName.contains("strict press") {
            return getOverheadPressRank(ratio: ratio)
        }
        // Rowing movements
        else if normalizedName.contains("row") || normalizedName.contains("bent over row") ||
                normalizedName.contains("barbell row") || normalizedName.contains("t-bar row") {
            return getRowRank(ratio: ratio)
        }
        // Push-ups (bodyweight exercise - ratio based on reps/1RM)
        else if normalizedName.contains("push up") || normalizedName.contains("push-up") || normalizedName.contains("pushup") {
            return getPushUpRank(ratio: ratio)
        }
        // Pull-ups and chin-ups (bodyweight + added weight)
        else if normalizedName.contains("pull up") || normalizedName.contains("pull-up") ||
                normalizedName.contains("chin up") || normalizedName.contains("chin-up") {
            return getPullUpRank(ratio: ratio)
        }
        // Dips (bodyweight + added weight)
        else if normalizedName.contains("dip") && !normalizedName.contains("deadlift") {
            return getDipRank(ratio: ratio)
        }
        // Curls and isolation work
        else if normalizedName.contains("curl") || normalizedName.contains("bicep") {
            return getCurlRank(ratio: ratio)
        }
        // Leg press
        else if normalizedName.contains("leg press") {
            return getLegPressRank(ratio: ratio)
        }
        // General compound movements
        else {
            return getGeneralRank(ratio: ratio)
        }
    }

    private static func getSquatRank(ratio: Double) -> StrengthRank {
        if ratio >= 2.5 { return .superman }
        if ratio >= 2.0 { return .hulk }
        if ratio >= 1.75 { return .arnold }
        if ratio >= 1.5 { return .diamond }
        if ratio >= 1.25 { return .platinum }
        if ratio >= 1.0 { return .gold }
        if ratio >= 0.75 { return .silver }
        return .bronze
    }

    private static func getBenchRank(ratio: Double) -> StrengthRank {
        if ratio >= 2.0 { return .superman }
        if ratio >= 1.75 { return .hulk }
        if ratio >= 1.5 { return .arnold }
        if ratio >= 1.25 { return .diamond }
        if ratio >= 1.0 { return .platinum }
        if ratio >= 0.85 { return .gold }
        if ratio >= 0.7 { return .silver }
        return .bronze
    }

    private static func getDeadliftRank(ratio: Double) -> StrengthRank {
        if ratio >= 3.0 { return .superman }
        if ratio >= 2.5 { return .hulk }
        if ratio >= 2.25 { return .arnold }
        if ratio >= 2.0 { return .diamond }
        if ratio >= 1.75 { return .platinum }
        if ratio >= 1.5 { return .gold }
        if ratio >= 1.25 { return .silver }
        return .bronze
    }

    private static func getOverheadPressRank(ratio: Double) -> StrengthRank {
        if ratio >= 1.5 { return .superman }
        if ratio >= 1.25 { return .hulk }
        if ratio >= 1.0 { return .arnold }
        if ratio >= 0.85 { return .diamond }
        if ratio >= 0.7 { return .platinum }
        if ratio >= 0.6 { return .gold }
        if ratio >= 0.5 { return .silver }
        return .bronze
    }

    private static func getRowRank(ratio: Double) -> StrengthRank {
        if ratio >= 1.75 { return .superman }
        if ratio >= 1.5 { return .hulk }
        if ratio >= 1.25 { return .arnold }
        if ratio >= 1.0 { return .diamond }
        if ratio >= 0.85 { return .platinum }
        if ratio >= 0.7 { return .gold }
        if ratio >= 0.6 { return .silver }
        return .bronze
    }

    private static func getPushUpRank(ratio: Double) -> StrengthRank {
        // For push-ups: The Brzycki formula breaks down at high reps (goes to infinity)
        // Push-ups are VERY EASY - extremely harsh standards
        // Rep examples: 12=1.44, 20=1.8, 25=3.0, 30=5.14, 36=18.3, 40=19.5, 60=25.5, 100=37.5
        if ratio >= 35.0 { return .superman }     // 100+ reps (superhuman)
        if ratio >= 28.0 { return .hulk }         // 75+ reps (elite athlete)
        if ratio >= 23.0 { return .arnold }       // 55+ reps (very strong)
        if ratio >= 19.0 { return .diamond }      // 40+ reps (strong)
        if ratio >= 10.0 { return .platinum }     // 35+ reps (above average)
        if ratio >= 4.0 { return .gold }          // 30+ reps (average)
        if ratio >= 2.0 { return .silver }        // 22+ reps (below average)
        return .bronze                             // < 22 reps (beginner)
    }

    private static func getPullUpRank(ratio: Double) -> StrengthRank {
        // For pull-ups, ratio is (bodyweight + added weight) / bodyweight
        // Much stricter standards
        if ratio >= 2.0 { return .superman }
        if ratio >= 1.8 { return .hulk }
        if ratio >= 1.6 { return .arnold }
        if ratio >= 1.4 { return .diamond }
        if ratio >= 1.2 { return .platinum }
        if ratio >= 1.0 { return .gold }
        if ratio >= 0.8 { return .silver }
        return .bronze
    }

    private static func getDipRank(ratio: Double) -> StrengthRank {
        // For dips, ratio is (bodyweight + added weight) / bodyweight
        // Stricter standards - dips are challenging but achievable
        if ratio >= 2.2 { return .superman }
        if ratio >= 2.0 { return .hulk }
        if ratio >= 1.7 { return .arnold }
        if ratio >= 1.5 { return .diamond }
        if ratio >= 1.3 { return .platinum }
        if ratio >= 1.1 { return .gold }
        if ratio >= 0.9 { return .silver }
        return .bronze
    }

    private static func getCurlRank(ratio: Double) -> StrengthRank {
        if ratio >= 0.8 { return .superman }
        if ratio >= 0.7 { return .hulk }
        if ratio >= 0.6 { return .arnold }
        if ratio >= 0.5 { return .diamond }
        if ratio >= 0.4 { return .platinum }
        if ratio >= 0.35 { return .gold }
        if ratio >= 0.3 { return .silver }
        return .bronze
    }

    private static func getLegPressRank(ratio: Double) -> StrengthRank {
        if ratio >= 4.0 { return .superman }
        if ratio >= 3.5 { return .hulk }
        if ratio >= 3.0 { return .arnold }
        if ratio >= 2.5 { return .diamond }
        if ratio >= 2.0 { return .platinum }
        if ratio >= 1.75 { return .gold }
        if ratio >= 1.5 { return .silver }
        return .bronze
    }

    private static func getGeneralRank(ratio: Double) -> StrengthRank {
        if ratio >= 1.8 { return .superman }
        if ratio >= 1.5 { return .hulk }
        if ratio >= 1.25 { return .arnold }
        if ratio >= 1.0 { return .diamond }
        if ratio >= 0.85 { return .platinum }
        if ratio >= 0.7 { return .gold }
        if ratio >= 0.6 { return .silver }
        return .bronze
    }
}

// MARK: - Personal Record Detection
struct PersonalRecord {
    let exerciseName: String
    let previousMax: Double
    let newMax: Double
    let improvement: Double

    var improvementPercentage: Double {
        return ((newMax - previousMax) / previousMax) * 100
    }
}

extension Workout {
    func getHighestRank(bodyWeight: Double = 181) -> StrengthRank? {
        // Use stored bodyweight from the workout if available
        // If not stored, use a default of 181 lbs for old workouts (don't use current weight)
        let effectiveBodyWeight = self.bodyWeight ?? 181.0
        var highestRank: StrengthRank?

        print("🏋️ Calculating rank for workout '\(name)' with \(exercises.count) exercises (bodyweight: \(effectiveBodyWeight) lbs\(self.bodyWeight != nil ? " [stored]" : " [default]"))")

        for exercise in exercises {
            // Check if exercise has valid sets with weight and reps
            let validSets = exercise.sets.filter { $0.reps > 0 && $0.weight > 0 }
            guard !validSets.isEmpty else {
                print("🏋️ Exercise '\(exercise.name)': No valid sets (has \(exercise.sets.count) total sets)")
                continue
            }

            // Calculate one-rep max for each valid set and find the highest
            let oneRepMaxes = validSets.compactMap { set -> Double? in
                // Brzycki formula: 1RM = weight * (36 / (37 - reps))
                // Cap at 36 reps to avoid negative/infinite values
                if set.reps == 1 {
                    return set.weight
                } else if set.reps >= 36 {
                    // For very high reps, use a multiplier approach
                    // At 36 reps, Brzycki would be infinite. Use a linear extension instead.
                    // 35 reps = ratio ~18, so continue from there
                    let baseRatio = 18.0  // Approximate ratio at 35 reps
                    let extraReps = Double(set.reps) - 35.0
                    return set.weight * (baseRatio + extraReps * 0.3)  // Add 0.3x per rep beyond 35
                } else {
                    return set.weight * (36.0 / (37.0 - Double(set.reps)))
                }
            }

            guard let maxOneRepMax = oneRepMaxes.max(), maxOneRepMax > 0 else {
                print("🏋️ Exercise '\(exercise.name)': No valid one-rep max calculated")
                continue
            }

            let ratio = maxOneRepMax / effectiveBodyWeight
            let rank = StrengthStandards.getRank(
                exerciseName: exercise.name,
                weight: maxOneRepMax,
                bodyWeight: effectiveBodyWeight
            )

            print("🏋️ Exercise '\(exercise.name)': 1RM \(String(format: "%.1f", maxOneRepMax)) lbs, ratio \(String(format: "%.2f", ratio)), rank: \(rank.rawValue) \(rank.symbol)")

            if highestRank == nil {
                highestRank = rank
                print("🏋️ First rank found: \(rank.rawValue) \(rank.symbol)")
            } else {
                // Compare by enum order (later cases are higher ranks)
                let currentIndex = StrengthRank.allCases.firstIndex(of: rank) ?? 0
                let highestIndex = StrengthRank.allCases.firstIndex(of: highestRank!) ?? 0

                if currentIndex > highestIndex {
                    highestRank = rank
                    print("🏋️ New highest rank: \(rank.rawValue) \(rank.symbol)")
                }
            }
        }

        // Return the highest rank achieved (including Novice)
        let finalRank = highestRank
        print("🏋️ Final rank for workout '\(name)': \(finalRank?.rawValue ?? "No rank") \(finalRank?.symbol ?? "")")
        return finalRank
    }

    func detectPersonalRecords(comparedTo previousWorkouts: [Workout]) -> [PersonalRecord] {
        var personalRecords: [PersonalRecord] = []

        for exercise in exercises {
            // Calculate current one-rep max
            let currentOneRepMaxes = exercise.sets.compactMap { set -> Double? in
                guard set.reps > 0 && set.weight > 0 else { return nil }
                if set.reps == 1 {
                    return set.weight
                } else {
                    return set.weight * (36.0 / (37.0 - Double(set.reps)))
                }
            }

            guard let currentMax = currentOneRepMaxes.max(), currentMax > 0 else { continue }

            // Find the best previous one-rep max for this exercise across all workouts
            let previousOneRepMaxes = previousWorkouts
                .flatMap { $0.exercises }
                .filter { $0.name.lowercased() == exercise.name.lowercased() }
                .flatMap { $0.sets }
                .compactMap { set -> Double? in
                    guard set.reps > 0 && set.weight > 0 else { return nil }
                    if set.reps == 1 {
                        return set.weight
                    } else {
                        return set.weight * (36.0 / (37.0 - Double(set.reps)))
                    }
                }

            let previousMax = previousOneRepMaxes.max() ?? 0

            // Check if we have a new PR (allowing for 2.5 lb improvement to account for small plates)
            if previousMax > 0 && currentMax > (previousMax + 2.5) {
                let improvement = currentMax - previousMax
                personalRecords.append(PersonalRecord(
                    exerciseName: exercise.name,
                    previousMax: previousMax,
                    newMax: currentMax,
                    improvement: improvement
                ))
                print("🎉 NEW PR! \(exercise.name): \(String(format: "%.1f", previousMax)) lbs → \(String(format: "%.1f", currentMax)) lbs (+\(String(format: "%.1f", improvement)) lbs) [1RM]")
            }
        }

        return personalRecords
    }
}