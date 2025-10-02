import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

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
            height: data["height"] as? Double ?? 0,
            weight: data["weight"] as? Double ?? 0,
            goalType: data["goalType"] as? String ?? "maintain",
            targetWeight: data["targetWeight"] as? Double ?? 0,
            dailyCalorieGoal: data["dailyCalorieGoal"] as? Double ?? 2000,
            dailyProteinGoal: data["dailyProteinGoal"] as? Double ?? 150,
            weeklyWorkoutGoal: data["weeklyWorkoutGoal"] as? Int ?? 3
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
struct UserProfile: Codable {
    let displayName: String
    let email: String
    let height: Double
    let weight: Double
    let goalType: String
    let targetWeight: Double
    let dailyCalorieGoal: Double
    let dailyProteinGoal: Double
    let weeklyWorkoutGoal: Int
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}