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

        let workoutData: [String: Any] = [
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
                    "fat": entry.fat
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
    func saveUserProfile(_ profile: UserProfile) async throws {
        guard let userID = currentUserID else {
            throw FirestoreError.userNotAuthenticated
        }

        let profileData: [String: Any] = [
            "displayName": profile.displayName,
            "email": profile.email,
            "height": profile.height,
            "weight": profile.weight,
            "goalType": profile.goalType,
            "targetWeight": profile.targetWeight,
            "dailyCalorieGoal": profile.dailyCalorieGoal,
            "dailyProteinGoal": profile.dailyProteinGoal,
            "weeklyWorkoutGoal": profile.weeklyWorkoutGoal,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        try await db.collection("users")
            .document(userID)
            .collection("profile")
            .document("settings")
            .setData(profileData, merge: true)
    }

    func fetchUserProfile() async throws -> UserProfile? {
        guard let userID = currentUserID else {
            throw FirestoreError.userNotAuthenticated
        }

        let document = try await db.collection("users")
            .document(userID)
            .collection("profile")
            .document("settings")
            .getDocument()

        guard let data = document.data() else { return nil }
        return try parseUserProfile(from: data)
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

        return Workout(
            name: name,
            exercises: exercises,
            date: date,
            duration: duration
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

        return FoodEntry(
            id: id,
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }

    private func parseUserProfile(from data: [String: Any]) throws -> UserProfile {
        guard let displayName = data["displayName"] as? String,
              let email = data["email"] as? String else {
            throw FirestoreError.invalidData
        }

        return UserProfile(
            displayName: displayName,
            email: email,
            currentWeight: data["weight"] as? Double ?? data["currentWeight"] as? Double ?? 181,
            goalWeight: data["targetWeight"] as? Double ?? data["goalWeight"] as? Double ?? 175,
            height: data["height"] as? Double ?? 72,
            dailyCalories: Int(data["dailyCalorieGoal"] as? Double ?? data["dailyCalories"] as? Double ?? 2000),
            dailyProtein: Int(data["dailyProteinGoal"] as? Double ?? data["dailyProtein"] as? Double ?? 150),
            weeklyWorkoutGoal: data["weeklyWorkoutGoal"] as? Int ?? 4
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
         weeklyWorkoutGoal: Int = 4) {
        self.displayName = displayName
        self.email = email
        self.currentWeight = currentWeight
        self.goalWeight = goalWeight
        self.height = height
        self.dailyCalories = dailyCalories
        self.dailyProtein = dailyProtein
        self.weeklyWorkoutGoal = weeklyWorkoutGoal
    }
}

class UserProfileStore: ObservableObject {
    @Published var profile: UserProfile {
        didSet {
            saveProfile()
        }
    }

    private let userDefaultsKey = "userProfile"

    init() {
        // Try to load saved profile
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
        } else {
            // Use default profile
            self.profile = UserProfile()
        }
    }

    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
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