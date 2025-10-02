import Foundation

struct Food: Identifiable, Codable {
    let id: UUID
    var name: String
    var caloriesPerServing: Double
    var proteinPerServing: Double
    var carbsPerServing: Double
    var fatPerServing: Double
    var servingSize: String

    init(name: String, caloriesPerServing: Double, proteinPerServing: Double, carbsPerServing: Double, fatPerServing: Double, servingSize: String) {
        self.id = UUID()
        self.name = name
        self.caloriesPerServing = caloriesPerServing
        self.proteinPerServing = proteinPerServing
        self.carbsPerServing = carbsPerServing
        self.fatPerServing = fatPerServing
        self.servingSize = servingSize
    }
}

struct FoodEntry: Identifiable, Codable {
    let id: UUID
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var mealType: MealType

    init(id: UUID = UUID(), name: String, calories: Double, protein: Double, carbs: Double, fat: Double, mealType: MealType = .breakfast) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.mealType = mealType
    }
}

struct DailyNutrition: Identifiable, Codable {
    let id: UUID
    var date: Date
    var entries: [FoodEntry]

    var totalCalories: Double {
        entries.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        entries.reduce(0) { $0 + $1.protein }
    }

    var totalCarbs: Double {
        entries.reduce(0) { $0 + $1.carbs }
    }

    var totalFat: Double {
        entries.reduce(0) { $0 + $1.fat }
    }

    init(id: UUID = UUID(), date: Date = Date(), entries: [FoodEntry] = []) {
        self.id = id
        self.date = date
        self.entries = entries
    }
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}

struct NutritionGoals: Codable {
    var dailyCalories: Double
    var dailyProtein: Double
    var dailyCarbs: Double
    var dailyFat: Double

    init(calories: Double = 2000, protein: Double = 150, carbs: Double = 250, fat: Double = 65) {
        self.dailyCalories = calories
        self.dailyProtein = protein
        self.dailyCarbs = carbs
        self.dailyFat = fat
    }
}

class NutritionStore: ObservableObject {
    @Published var dailyNutrition: [DailyNutrition] = []
    @Published var nutritionGoals = NutritionGoals()
    @Published var foods: [Food] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let firestoreManager = FirestoreManager()

    init() {
        print("🔥 NutritionStore: Initializing...")
        loadSampleFoods()
        // Don't set up Firebase listeners immediately - wait for authentication
    }

    // MARK: - Firebase Integration
    func startFirebaseListeners() {
        setupFirestoreListeners()
    }

    private func setupFirestoreListeners() {
        print("🔥 NutritionStore: Setting up Firestore listeners...")
        firestoreManager.listenToNutrition { [weak self] (nutrition: [DailyNutrition]) in
            print("🔥 NutritionStore: Received \(nutrition.count) nutrition entries from Firestore")
            DispatchQueue.main.async {
                self?.dailyNutrition = nutrition
                self?.isLoading = false
            }
        }
    }

    func addFoodEntry(_ entry: FoodEntry, to date: Date = Date()) {
        print("🔥 NutritionStore: Adding food entry '\(entry.name)' to meal '\(entry.mealType.rawValue)'")
        let calendar = Calendar.current

        if let index = dailyNutrition.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            dailyNutrition[index].entries.append(entry)
            // Save updated nutrition to Firebase
            Task {
                await saveDailyNutrition(dailyNutrition[index])
            }
        } else {
            let newDailyNutrition = DailyNutrition(date: date, entries: [entry])
            dailyNutrition.append(newDailyNutrition)
            // Save new nutrition to Firebase
            Task {
                await saveDailyNutrition(newDailyNutrition)
            }
        }
    }

    func deleteFoodEntry(_ entry: FoodEntry, from date: Date = Date()) {
        print("🔥 NutritionStore: Deleting food entry '\(entry.name)' from meal '\(entry.mealType.rawValue)'")
        let calendar = Calendar.current

        if let dayIndex = dailyNutrition.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            dailyNutrition[dayIndex].entries.removeAll { $0.id == entry.id }

            // Save updated nutrition to Firebase
            Task {
                await saveDailyNutrition(dailyNutrition[dayIndex])
            }
        }
    }

    func updateFoodEntry(_ originalEntry: FoodEntry, with updatedEntry: FoodEntry, on date: Date = Date()) {
        print("🔥 NutritionStore: Updating food entry '\(originalEntry.name)' to '\(updatedEntry.name)'")
        let calendar = Calendar.current

        if let dayIndex = dailyNutrition.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }),
           let entryIndex = dailyNutrition[dayIndex].entries.firstIndex(where: { $0.id == originalEntry.id }) {

            // Update the entry in place, preserving the original ID
            var updated = updatedEntry
            updated = FoodEntry(
                id: originalEntry.id,
                name: updatedEntry.name,
                calories: updatedEntry.calories,
                protein: updatedEntry.protein,
                carbs: updatedEntry.carbs,
                fat: updatedEntry.fat,
                mealType: updatedEntry.mealType
            )

            dailyNutrition[dayIndex].entries[entryIndex] = updated

            // Save updated nutrition to Firebase
            Task {
                await saveDailyNutrition(dailyNutrition[dayIndex])
            }
        }
    }

    func saveDailyNutrition(_ nutrition: DailyNutrition) async {
        print("🔥 NutritionStore: Attempting to save nutrition for date \(nutrition.date)")
        do {
            try await firestoreManager.saveDailyNutrition(nutrition)
            print("🔥 NutritionStore: Successfully saved nutrition for \(nutrition.date) to Firestore")
        } catch {
            print("🔥 NutritionStore: Failed to save nutrition: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Failed to save nutrition: \(error.localizedDescription)"
            }
        }
    }

    func getTodayNutrition() -> DailyNutrition? {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyNutrition.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    func todaysTotals() -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        guard let todayNutrition = getTodayNutrition() else {
            return (0, 0, 0, 0)
        }
        return (todayNutrition.totalCalories, todayNutrition.totalProtein, todayNutrition.totalCarbs, todayNutrition.totalFat)
    }

    private func loadSampleFoods() {
        // Only load sample foods if foods array is empty
        guard foods.isEmpty else { return }

        foods = [
            Food(name: "Chicken Breast", caloriesPerServing: 231, proteinPerServing: 43.5, carbsPerServing: 0, fatPerServing: 5, servingSize: "100g"),
            Food(name: "Brown Rice", caloriesPerServing: 111, proteinPerServing: 2.6, carbsPerServing: 23, fatPerServing: 0.9, servingSize: "100g"),
            Food(name: "Broccoli", caloriesPerServing: 34, proteinPerServing: 2.8, carbsPerServing: 7, fatPerServing: 0.4, servingSize: "100g"),
            Food(name: "Banana", caloriesPerServing: 89, proteinPerServing: 1.1, carbsPerServing: 23, fatPerServing: 0.3, servingSize: "1 medium"),
            Food(name: "Greek Yogurt", caloriesPerServing: 59, proteinPerServing: 10, carbsPerServing: 3.6, fatPerServing: 0.4, servingSize: "100g"),
            Food(name: "Oatmeal", caloriesPerServing: 154, proteinPerServing: 5.3, carbsPerServing: 28, fatPerServing: 2.5, servingSize: "1 cup"),
            Food(name: "Salmon", caloriesPerServing: 208, proteinPerServing: 25.4, carbsPerServing: 0, fatPerServing: 12.4, servingSize: "100g"),
            Food(name: "Apple", caloriesPerServing: 95, proteinPerServing: 0.5, carbsPerServing: 25, fatPerServing: 0.3, servingSize: "1 medium")
        ]
    }

    deinit {
        firestoreManager.removeAllListeners()
    }
}