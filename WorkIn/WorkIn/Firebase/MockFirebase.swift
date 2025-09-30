import Foundation

// Mock Firebase implementation for testing without actual Firebase setup
// Replace with real Firebase when dependencies are added to Xcode project

struct MockUser {
    let uid: String
    let isAnonymous: Bool

    init(uid: String = UUID().uuidString, isAnonymous: Bool = true) {
        self.uid = uid
        self.isAnonymous = isAnonymous
    }
}

class MockFirebaseManager: ObservableObject {
    static let shared = MockFirebaseManager()

    @Published var isUserAuthenticated = false
    @Published var currentUser: MockUser?

    private var workoutStorage: [String: [Workout]] = [:]
    private var nutritionStorage: [String: [DailyNutrition]] = [:]

    init() {
        // Auto sign in as guest for demo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.signInAnonymously()
        }
    }

    // MARK: - Authentication
    func signInAnonymously() {
        let user = MockUser()
        DispatchQueue.main.async {
            self.currentUser = user
            self.isUserAuthenticated = true
        }
    }

    func signInWithEmail(_ email: String, password: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let user = MockUser(isAnonymous: false)
        DispatchQueue.main.async {
            self.currentUser = user
            self.isUserAuthenticated = true
        }
    }

    func createAccount(email: String, password: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let user = MockUser(isAnonymous: false)
        DispatchQueue.main.async {
            self.currentUser = user
            self.isUserAuthenticated = true
        }
    }

    func signOut() throws {
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isUserAuthenticated = false
        }
    }

    // MARK: - Firestore Operations
    func saveWorkout(_ workout: Workout) async throws {
        guard let userId = currentUser?.uid else {
            throw MockFirebaseError.userNotAuthenticated
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        if workoutStorage[userId] == nil {
            workoutStorage[userId] = []
        }
        workoutStorage[userId]?.append(workout)
    }

    func loadWorkouts() async throws -> [Workout] {
        guard let userId = currentUser?.uid else {
            throw MockFirebaseError.userNotAuthenticated
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        return workoutStorage[userId] ?? []
    }

    func saveNutritionEntry(_ nutrition: DailyNutrition) async throws {
        guard let userId = currentUser?.uid else {
            throw MockFirebaseError.userNotAuthenticated
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        if nutritionStorage[userId] == nil {
            nutritionStorage[userId] = []
        }

        // Update existing entry for the same date or add new one
        if let index = nutritionStorage[userId]?.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: nutrition.date) }) {
            nutritionStorage[userId]?[index] = nutrition
        } else {
            nutritionStorage[userId]?.append(nutrition)
        }
    }

    func loadNutritionEntries() async throws -> [DailyNutrition] {
        guard let userId = currentUser?.uid else {
            throw MockFirebaseError.userNotAuthenticated
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        return nutritionStorage[userId] ?? []
    }
}

enum MockFirebaseError: Error, LocalizedError {
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