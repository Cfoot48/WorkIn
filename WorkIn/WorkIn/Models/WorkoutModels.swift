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
        print("🔥 WorkoutStore: Initializing...")
        // Delay Firebase setup to ensure user is authenticated
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.setupFirestoreListeners()
        }

        // Test the ranking system immediately
        testRankingSystem()

        // TEMPORARILY: Load sample data immediately to show rankings
        loadSampleData()
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
    case novice = "Novice"
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case elite = "Elite"
    case worldClass = "World Class"

    var symbol: String {
        switch self {
        case .novice: return "🥉"
        case .beginner: return "🥈"
        case .intermediate: return "🥇"
        case .advanced: return "💎"
        case .elite: return "👑"
        case .worldClass: return "🏆"
        }
    }

    var color: String {
        switch self {
        case .novice: return "brown"
        case .beginner: return "gray"
        case .intermediate: return "orange"
        case .advanced: return "blue"
        case .elite: return "purple"
        case .worldClass: return "red"
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
        if ratio >= 2.5 { return .worldClass }
        if ratio >= 2.0 { return .elite }
        if ratio >= 1.75 { return .advanced }
        if ratio >= 1.5 { return .intermediate }
        if ratio >= 1.25 { return .beginner }
        return .novice
    }

    private static func getBenchRank(ratio: Double) -> StrengthRank {
        if ratio >= 2.0 { return .worldClass }
        if ratio >= 1.75 { return .elite }
        if ratio >= 1.5 { return .advanced }
        if ratio >= 1.25 { return .intermediate }
        if ratio >= 1.0 { return .beginner }
        return .novice
    }

    private static func getDeadliftRank(ratio: Double) -> StrengthRank {
        if ratio >= 3.0 { return .worldClass }
        if ratio >= 2.5 { return .elite }
        if ratio >= 2.25 { return .advanced }
        if ratio >= 2.0 { return .intermediate }
        if ratio >= 1.5 { return .beginner }
        return .novice
    }

    private static func getOverheadPressRank(ratio: Double) -> StrengthRank {
        if ratio >= 1.5 { return .worldClass }
        if ratio >= 1.25 { return .elite }
        if ratio >= 1.0 { return .advanced }
        if ratio >= 0.85 { return .intermediate }
        if ratio >= 0.7 { return .beginner }
        return .novice
    }

    private static func getRowRank(ratio: Double) -> StrengthRank {
        if ratio >= 1.75 { return .worldClass }
        if ratio >= 1.5 { return .elite }
        if ratio >= 1.25 { return .advanced }
        if ratio >= 1.0 { return .intermediate }
        if ratio >= 0.85 { return .beginner }
        return .novice
    }

    private static func getPullUpRank(ratio: Double) -> StrengthRank {
        // For pull-ups, ratio is (bodyweight + added weight) / bodyweight
        if ratio >= 1.8 { return .worldClass }
        if ratio >= 1.6 { return .elite }
        if ratio >= 1.4 { return .advanced }
        if ratio >= 1.2 { return .intermediate }
        if ratio >= 1.0 { return .beginner }
        return .novice
    }

    private static func getDipRank(ratio: Double) -> StrengthRank {
        // For dips, ratio is (bodyweight + added weight) / bodyweight
        if ratio >= 1.9 { return .worldClass }
        if ratio >= 1.7 { return .elite }
        if ratio >= 1.5 { return .advanced }
        if ratio >= 1.3 { return .intermediate }
        if ratio >= 1.0 { return .beginner }
        return .novice
    }

    private static func getCurlRank(ratio: Double) -> StrengthRank {
        if ratio >= 0.8 { return .worldClass }
        if ratio >= 0.7 { return .elite }
        if ratio >= 0.6 { return .advanced }
        if ratio >= 0.5 { return .intermediate }
        if ratio >= 0.4 { return .beginner }
        return .novice
    }

    private static func getLegPressRank(ratio: Double) -> StrengthRank {
        if ratio >= 4.0 { return .worldClass }
        if ratio >= 3.5 { return .elite }
        if ratio >= 3.0 { return .advanced }
        if ratio >= 2.5 { return .intermediate }
        if ratio >= 2.0 { return .beginner }
        return .novice
    }

    private static func getGeneralRank(ratio: Double) -> StrengthRank {
        if ratio >= 1.8 { return .worldClass }
        if ratio >= 1.5 { return .elite }
        if ratio >= 1.25 { return .advanced }
        if ratio >= 1.0 { return .intermediate }
        if ratio >= 0.8 { return .beginner }
        return .novice
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
        var highestRank: StrengthRank?

        print("🏋️ Calculating rank for workout '\(name)' with \(exercises.count) exercises (bodyweight: \(bodyWeight) lbs)")

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
                if set.reps == 1 {
                    return set.weight
                } else {
                    return set.weight * (36.0 / (37.0 - Double(set.reps)))
                }
            }

            guard let maxOneRepMax = oneRepMaxes.max(), maxOneRepMax > 0 else {
                print("🏋️ Exercise '\(exercise.name)': No valid one-rep max calculated")
                continue
            }

            let ratio = maxOneRepMax / bodyWeight
            let rank = StrengthStandards.getRank(
                exerciseName: exercise.name,
                weight: maxOneRepMax,
                bodyWeight: bodyWeight
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

        // Only return ranks that are Beginner or higher (filter out Novice for display)
        let finalRank = highestRank
        let displayRank = (finalRank == .novice) ? nil : finalRank
        print("🏋️ Final rank for workout '\(name)': \(displayRank?.rawValue ?? "No rank") \(displayRank?.symbol ?? "")")
        return displayRank
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