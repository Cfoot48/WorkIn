import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    @Published var isUserAuthenticated = false
    @Published var currentUser: User?

    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    init() {
        configureFirebase()
        checkAuthenticationState()
    }

    private func configureFirebase() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    private func checkAuthenticationState() {
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isUserAuthenticated = user != nil
            }
        }
    }

    // MARK: - Authentication
    func signInAnonymously() async throws {
        do {
            let result = try await auth.signInAnonymously()
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isUserAuthenticated = true
            }
        } catch {
            print("Failed to sign in anonymously: \(error.localizedDescription)")
            throw error
        }
    }

    func signInWithEmail(_ email: String, password: String) async throws {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isUserAuthenticated = true
            }
        } catch {
            print("Failed to sign in with email: \(error.localizedDescription)")
            throw error
        }
    }

    func createAccount(email: String, password: String) async throws {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isUserAuthenticated = true
            }
        } catch {
            print("Failed to create account: \(error.localizedDescription)")
            throw error
        }
    }

    func signOut() throws {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isUserAuthenticated = false
            }
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Firestore Operations
    func saveWorkout(_ workout: Workout) async throws {
        guard let userId = currentUser?.uid else {
            throw FirebaseError.userNotAuthenticated
        }

        let workoutData: [String: Any] = [
            "id": workout.id.uuidString,
            "name": workout.name,
            "date": Timestamp(date: workout.date),
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
            }
        ]

        try await db.collection("users").document(userId).collection("workouts").document(workout.id.uuidString).setData(workoutData)
    }

    func loadWorkouts() async throws -> [Workout] {
        guard let userId = currentUser?.uid else {
            throw FirebaseError.userNotAuthenticated
        }

        let snapshot = try await db.collection("users").document(userId).collection("workouts").getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()

            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let name = data["name"] as? String,
                  let timestamp = data["date"] as? Timestamp,
                  let duration = data["duration"] as? TimeInterval,
                  let exercisesData = data["exercises"] as? [[String: Any]] else {
                return nil
            }

            let exercises = exercisesData.compactMap { exerciseData -> Exercise? in
                guard let exerciseIdString = exerciseData["id"] as? String,
                      let exerciseId = UUID(uuidString: exerciseIdString),
                      let exerciseName = exerciseData["name"] as? String,
                      let muscleGroups = exerciseData["muscleGroups"] as? [String],
                      let equipment = exerciseData["equipment"] as? String,
                      let setsData = exerciseData["sets"] as? [[String: Any]] else {
                    return nil
                }

                let sets = setsData.compactMap { setData -> ExerciseSet? in
                    guard let setIdString = setData["id"] as? String,
                          let setId = UUID(uuidString: setIdString),
                          let reps = setData["reps"] as? Int,
                          let weight = setData["weight"] as? Double,
                          let restTime = setData["restTime"] as? Double,
                          let completed = setData["completed"] as? Bool else {
                        return nil
                    }

                    return ExerciseSet(id: setId, reps: reps, weight: weight, restTime: restTime, completed: completed)
                }

                return Exercise(id: exerciseId, name: exerciseName, muscleGroups: muscleGroups, equipment: equipment, sets: sets)
            }

            return Workout(id: id, name: name, exercises: exercises, date: timestamp.dateValue(), duration: duration)
        }
    }

    func saveNutritionEntry(_ nutrition: DailyNutrition) async throws {
        guard let userId = currentUser?.uid else {
            throw FirebaseError.userNotAuthenticated
        }

        let nutritionData: [String: Any] = [
            "id": nutrition.id.uuidString,
            "date": Timestamp(date: nutrition.date),
            "entries": nutrition.entries.map { entry in
                [
                    "id": entry.id.uuidString,
                    "name": entry.name,
                    "calories": entry.calories,
                    "protein": entry.protein,
                    "carbs": entry.carbs,
                    "fat": entry.fat
                ]
            }
        ]

        try await db.collection("users").document(userId).collection("nutrition").document(nutrition.id.uuidString).setData(nutritionData)
    }

    func loadNutritionEntries() async throws -> [DailyNutrition] {
        guard let userId = currentUser?.uid else {
            throw FirebaseError.userNotAuthenticated
        }

        let snapshot = try await db.collection("users").document(userId).collection("nutrition").getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()

            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let timestamp = data["date"] as? Timestamp,
                  let entriesData = data["entries"] as? [[String: Any]] else {
                return nil
            }

            let entries = entriesData.compactMap { entryData -> FoodEntry? in
                guard let entryIdString = entryData["id"] as? String,
                      let entryId = UUID(uuidString: entryIdString),
                      let name = entryData["name"] as? String,
                      let calories = entryData["calories"] as? Double,
                      let protein = entryData["protein"] as? Double,
                      let carbs = entryData["carbs"] as? Double,
                      let fat = entryData["fat"] as? Double else {
                    return nil
                }

                return FoodEntry(id: entryId, name: name, calories: calories, protein: protein, carbs: carbs, fat: fat)
            }

            return DailyNutrition(id: id, date: timestamp.dateValue(), entries: entries)
        }
    }
}

enum FirebaseError: Error, LocalizedError {
    case userNotAuthenticated
    case documentNotFound
    case invalidData

    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not authenticated"
        case .documentNotFound:
            return "Document not found"
        case .invalidData:
            return "Invalid data format"
        }
    }
}