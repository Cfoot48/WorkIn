import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine
import SwiftUI

class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    // MARK: - User Management
    private var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }

    // MARK: - Workout Operations
    func saveWorkout(_ workout: Workout) async throws {
        guard let userID = currentUserID else {
            throw FirestoreError.userNotAuthenticated
        }

        var workoutData: [String: Any] = [
            "id": workout.id.uuidString,
            "name": workout.name,
            "date": workout.date,
            "duration": workout.duration,
            "exercises": workout.exercises.map { exercise in
                [
                    "id": exercise.id.uuidString,
                    "name": exercise.name,
                    "muscleGroups": exercise.muscleGroups,
                    "equipment": exercise.equipment,
                    "sets": exercise.sets.map { set in
                        [
                            "id": set.id.uuidString,
                            "reps": set.reps,
                            "weight": set.weight,
                            "restTime": set.restTime,
                            "completed": set.completed
                        ]
                    }
                ]
            },
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        // Add bodyweight if available
        if let bodyWeight = workout.bodyWeight {
            workoutData["bodyWeight"] = bodyWeight
        }

        try await db.collection("users")
            .document(userID)
            .collection("workouts")
            .document(workout.id.uuidString)
            .setData(workoutData)
    }

    func fetchWorkouts() async throws -> [Workout] {
        guard let userID = currentUserID else {
            throw FirestoreError.userNotAuthenticated
        }

        let snapshot = try await db.collection("users")
            .document(userID)
            .collection("workouts")
            .order(by: "date", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            try? self.parseWorkout(from: document.data(), id: document.documentID)
        }
    }

    func deleteWorkout(_ workoutID: String) async throws {
        guard let userID = currentUserID else {
            throw FirestoreError.userNotAuthenticated
        }

        try await db.collection("users")
            .document(userID)
            .collection("workouts")
            .document(workoutID)
            .delete()
    }

    // MARK: - Nutrition Operations
    func saveDailyNutrition(_ nutrition: DailyNutrition) async throws {
        guard let userID = currentUserID else {
            throw FirestoreError.userNotAuthenticated
        }

        let nutritionData: [String: Any] = [
            "date": nutrition.date,
            "entries": nutrition.entries.map { entry in
                [
                    "id": entry.id.uuidString,
                    "name": entry.name,
                    "calories": entry.calories,
                    "protein": entry.protein,
                    "carbs": entry.carbs,
                    "fat": entry.fat,
                    "mealType": entry.mealType.rawValue
                ]
            },
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        let dateString = DateFormatter.dateOnly.string(from: nutrition.date)
        try await db.collection("users")
            .document(userID)
            .collection("nutrition")
            .document(dateString)
            .setData(nutritionData)
    }

    func fetchNutrition(for date: Date) async throws -> DailyNutrition? {
        guard let userID = currentUserID else {
            throw FirestoreError.userNotAuthenticated
        }

        let dateString = DateFormatter.dateOnly.string(from: date)
        let document = try await db.collection("users")
            .document(userID)
            .collection("nutrition")
            .document(dateString)
            .getDocument()

        guard let data = document.data() else { return nil }
        return try parseNutrition(from: data)
    }

    // MARK: - Real-time Listeners
    func listenToWorkouts(completion: @escaping ([Workout]) -> Void) {
        guard let userID = currentUserID else { return }

        let listener = db.collection("users")
            .document(userID)
            .collection("workouts")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print("Error fetching workouts: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                let workouts = snapshot.documents.compactMap { document in
                    try? self.parseWorkout(from: document.data(), id: document.documentID)
                }
                completion(workouts)
            }

        listeners.append(listener)
    }

    func listenToNutrition(completion: @escaping ([DailyNutrition]) -> Void) {
        guard let userID = currentUserID else { return }

        print("🔥 FirestoreManager: Setting up nutrition listener...")
        let listener = db.collection("users")
            .document(userID)
            .collection("nutrition")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    print("🔥 Error fetching nutrition: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                print("🔥 FirestoreManager: Received \(snapshot.documents.count) nutrition documents from Firestore")
                let nutrition = snapshot.documents.compactMap { document in
                    try? self.parseNutrition(from: document.data())
                }
                print("🔥 FirestoreManager: Successfully parsed \(nutrition.count) nutrition entries")
                completion(nutrition)
            }

        listeners.append(listener)
    }

    func removeAllListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }

    // MARK: - User Profile Operations
    func saveUserProfile(_ profile: UserProfile, hasCompletedOnboarding: Bool) async throws {
        guard let userID = currentUserID else {
            throw FirestoreError.userNotAuthenticated
        }

        var profileData: [String: Any] = [
            "displayName": profile.displayName,
            "email": profile.email,
            "height": profile.height,
            "weight": profile.weight,
            "targetWeight": profile.targetWeight,
            "dailyCalorieGoal": profile.dailyCalorieGoal,
            "dailyProteinGoal": profile.dailyProteinGoal,
            "weeklyWorkoutGoal": profile.weeklyWorkoutGoal,
            "hasCompletedOnboarding": hasCompletedOnboarding,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if let rank = profile.highestRankAchieved {
            profileData["highestRankAchieved"] = rank.rawValue
        }

        try await db.collection("users")
            .document(userID)
            .collection("profile")
            .document("settings")
            .setData(profileData, merge: true)
    }

    func fetchUserProfile() async throws -> (profile: UserProfile?, hasCompletedOnboarding: Bool) {
        guard let userID = currentUserID else {
            throw FirestoreError.userNotAuthenticated
        }

        let document = try await db.collection("users")
            .document(userID)
            .collection("profile")
            .document("settings")
            .getDocument()

        guard let data = document.data() else {
            return (profile: nil, hasCompletedOnboarding: false)
        }

        let hasCompletedOnboarding = data["hasCompletedOnboarding"] as? Bool ?? false
        let profile = try parseUserProfile(from: data)
        return (profile: profile, hasCompletedOnboarding: hasCompletedOnboarding)
    }

    // MARK: - Private Parsing Methods
    private func parseWorkout(from data: [String: Any], id: String) throws -> Workout {
        guard let name = data["name"] as? String,
              let date = (data["date"] as? Timestamp)?.dateValue(),
              let duration = data["duration"] as? TimeInterval,
              let exercisesData = data["exercises"] as? [[String: Any]] else {
            throw FirestoreError.invalidData
        }

        let exercises = try exercisesData.map { exerciseData in
            try parseExercise(from: exerciseData)
        }

        // Bodyweight is optional for backwards compatibility
        let bodyWeight = data["bodyWeight"] as? Double

        return Workout(
            name: name,
            exercises: exercises,
            date: date,
            duration: duration,
            bodyWeight: bodyWeight
        )
    }

    private func parseExercise(from data: [String: Any]) throws -> Exercise {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = data["name"] as? String,
              let muscleGroups = data["muscleGroups"] as? [String],
              let equipment = data["equipment"] as? String,
              let setsData = data["sets"] as? [[String: Any]] else {
            throw FirestoreError.invalidData
        }

        let sets = try setsData.map { setData in
            try parseExerciseSet(from: setData)
        }

        return Exercise(
            id: id,
            name: name,
            sets: sets,
            muscleGroups: muscleGroups,
            equipment: equipment
        )
    }

    private func parseExerciseSet(from data: [String: Any]) throws -> ExerciseSet {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let reps = data["reps"] as? Int,
              let weight = data["weight"] as? Double,
              let restTime = data["restTime"] as? Double,
              let completed = data["completed"] as? Bool else {
            throw FirestoreError.invalidData
        }

        return ExerciseSet(
            id: id,
            reps: reps,
            weight: weight,
            restTime: restTime,
            completed: completed
        )
    }

    private func parseNutrition(from data: [String: Any]) throws -> DailyNutrition {
        guard let date = (data["date"] as? Timestamp)?.dateValue(),
              let entriesData = data["entries"] as? [[String: Any]] else {
            throw FirestoreError.invalidData
        }

        let entries = try entriesData.map { entryData in
            try parseFoodEntry(from: entryData)
        }

        return DailyNutrition(date: date, entries: entries)
    }

    private func parseFoodEntry(from data: [String: Any]) throws -> FoodEntry {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = data["name"] as? String,
              let calories = data["calories"] as? Double,
              let protein = data["protein"] as? Double,
              let carbs = data["carbs"] as? Double,
              let fat = data["fat"] as? Double else {
            throw FirestoreError.invalidData
        }

        // Parse meal type with fallback to breakfast for backwards compatibility
        let mealTypeString = data["mealType"] as? String ?? "Breakfast"
        let mealType = MealType(rawValue: mealTypeString) ?? .breakfast

        return FoodEntry(
            id: id,
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            mealType: mealType
        )
    }

    private func parseUserProfile(from data: [String: Any]) throws -> UserProfile {
        guard let displayName = data["displayName"] as? String,
              let email = data["email"] as? String else {
            throw FirestoreError.invalidData
        }

        let rankString = data["highestRankAchieved"] as? String
        let rank = rankString != nil ? StrengthRank(rawValue: rankString!) : nil

        return UserProfile(
            displayName: displayName,
            email: email,
            currentWeight: data["weight"] as? Double ?? data["currentWeight"] as? Double ?? 181,
            goalWeight: data["targetWeight"] as? Double ?? data["goalWeight"] as? Double ?? 175,
            height: data["height"] as? Double ?? 72,
            dailyCalories: Int(data["dailyCalorieGoal"] as? Double ?? data["dailyCalories"] as? Double ?? 2000),
            dailyProtein: Int(data["dailyProteinGoal"] as? Double ?? data["dailyProtein"] as? Double ?? 150),
            weeklyWorkoutGoal: data["weeklyWorkoutGoal"] as? Int ?? 4,
            highestRankAchieved: rank
        )
    }
}

// MARK: - Error Types
enum FirestoreError: Error, LocalizedError {
    case userNotAuthenticated
    case invalidData
    case documentNotFound

    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        case .invalidData:
            return "Invalid data format"
        case .documentNotFound:
            return "Document not found"
        }
    }
}

// MARK: - User Profile Model
enum GoalType: String, Codable, CaseIterable {
    case cut = "Cut"
    case bulk = "Bulk"
    case maintain = "Maintain"

    var color: Color {
        switch self {
        case .cut: return .red
        case .bulk: return .green
        case .maintain: return .blue
        }
    }
}

struct UserProfile: Codable {
    var displayName: String
    var email: String
    var height: Double // in inches
    var currentWeight: Double
    var goalWeight: Double
    var dailyCalories: Int
    var dailyProtein: Int
    var weeklyWorkoutGoal: Int
    var highestRankAchieved: StrengthRank?

    var goalType: GoalType {
        if goalWeight < currentWeight {
            return .cut
        } else if goalWeight > currentWeight {
            return .bulk
        } else {
            return .maintain
        }
    }

    var heightFormatted: String {
        let feet = Int(height) / 12
        let inches = Int(height) % 12
        return "\(feet)'\(inches)\""
    }

    // Keep old property names for backwards compatibility
    var weight: Double {
        get { currentWeight }
        set { currentWeight = newValue }
    }

    var targetWeight: Double {
        get { goalWeight }
        set { goalWeight = newValue }
    }

    var dailyCalorieGoal: Double {
        get { Double(dailyCalories) }
        set { dailyCalories = Int(newValue) }
    }

    var dailyProteinGoal: Double {
        get { Double(dailyProtein) }
        set { dailyProtein = Int(newValue) }
    }

    init(displayName: String = "",
         email: String = "",
         currentWeight: Double = 181,
         goalWeight: Double = 175,
         height: Double = 72, // 6'0"
         dailyCalories: Int = 2000,
         dailyProtein: Int = 150,
         weeklyWorkoutGoal: Int = 4,
         highestRankAchieved: StrengthRank? = nil) {
        self.displayName = displayName
        self.email = email
        self.currentWeight = currentWeight
        self.goalWeight = goalWeight
        self.height = height
        self.dailyCalories = dailyCalories
        self.dailyProtein = dailyProtein
        self.weeklyWorkoutGoal = weeklyWorkoutGoal
        self.highestRankAchieved = highestRankAchieved
    }
}

class UserProfileStore: ObservableObject {
    @Published var profile: UserProfile {
        didSet {
            if shouldSave {
                saveProfile()
            }
        }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet {
            if shouldSave {
                saveProfile()
            }
        }
    }

    @Published var isLoadingProfile: Bool = false

    private let firestoreManager = FirestoreManager()
    private var isSaving = false
    private var shouldSave = false

    init() {
        // Create empty profile - will be loaded when user signs in
        self.profile = UserProfile(
            currentWeight: 0,
            goalWeight: 0,
            height: 0,
            dailyCalories: 0,
            dailyProtein: 0,
            weeklyWorkoutGoal: 0
        )
        self.hasCompletedOnboarding = false
        // Enable saving immediately so onboarding completion can save
        self.shouldSave = true
    }

    func resetProfile() {
        shouldSave = false
        hasCompletedOnboarding = false
        isLoadingProfile = false
        profile = UserProfile(
            currentWeight: 0,
            goalWeight: 0,
            height: 0,
            dailyCalories: 0,
            dailyProtein: 0,
            weeklyWorkoutGoal: 0
        )
    }

    // Load profile from Firestore when user signs in
    func loadProfile() async {
        await MainActor.run {
            isLoadingProfile = true
        }

        shouldSave = false // Disable saving during load
        do {
            let result = try await firestoreManager.fetchUserProfile()
            await MainActor.run {
                if let loadedProfile = result.profile {
                    self.profile = loadedProfile
                    self.hasCompletedOnboarding = result.hasCompletedOnboarding
                    print("✅ Profile loaded from Firestore: \(loadedProfile.displayName)")
                } else {
                    // No profile exists yet - user needs to complete onboarding
                    self.hasCompletedOnboarding = false
                    print("ℹ️ No profile found in Firestore - showing onboarding")
                }
                shouldSave = true // Enable saving after load completes
                isLoadingProfile = false
            }
        } catch {
            print("❌ Error loading profile: \(error.localizedDescription)")
            // On error, assume they need onboarding
            await MainActor.run {
                self.hasCompletedOnboarding = false
                shouldSave = true
                isLoadingProfile = false
            }
        }
    }

    private func saveProfile() {
        // Prevent recursive saves
        guard !isSaving else { return }
        isSaving = true

        Task {
            do {
                try await firestoreManager.saveUserProfile(profile, hasCompletedOnboarding: hasCompletedOnboarding)
                print("✅ Profile saved to Firestore")
            } catch {
                print("❌ Error saving profile: \(error.localizedDescription)")
            }
            isSaving = false
        }
    }

    // Explicit save function that can be called from onboarding
    func saveProfileExplicitly() async {
        do {
            try await firestoreManager.saveUserProfile(profile, hasCompletedOnboarding: hasCompletedOnboarding)
            print("✅ Profile explicitly saved to Firestore after onboarding")
        } catch {
            print("❌ Error saving profile after onboarding: \(error.localizedDescription)")
        }
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}