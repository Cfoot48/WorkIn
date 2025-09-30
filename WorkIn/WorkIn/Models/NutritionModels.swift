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

    init(id: UUID = UUID(), name: String, calories: Double, protein: Double, carbs: Double, fat: Double) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
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

    init() {
        loadSampleData()
    }

    func addFoodEntry(_ entry: FoodEntry, to date: Date = Date()) {
        let calendar = Calendar.current

        if let index = dailyNutrition.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            dailyNutrition[index].entries.append(entry)
        } else {
            let newDailyNutrition = DailyNutrition(date: date, entries: [entry])
            dailyNutrition.append(newDailyNutrition)
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

    private func loadSampleData() {
        foods = [
            Food(name: "Chicken Breast", caloriesPerServing: 231, proteinPerServing: 43.5, carbsPerServing: 0, fatPerServing: 5, servingSize: "100g"),
            Food(name: "Brown Rice", caloriesPerServing: 111, proteinPerServing: 2.6, carbsPerServing: 23, fatPerServing: 0.9, servingSize: "100g"),
            Food(name: "Broccoli", caloriesPerServing: 34, proteinPerServing: 2.8, carbsPerServing: 7, fatPerServing: 0.4, servingSize: "100g"),
            Food(name: "Banana", caloriesPerServing: 89, proteinPerServing: 1.1, carbsPerServing: 23, fatPerServing: 0.3, servingSize: "1 medium"),
            Food(name: "Greek Yogurt", caloriesPerServing: 59, proteinPerServing: 10, carbsPerServing: 3.6, fatPerServing: 0.4, servingSize: "100g")
        ]

        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today

        let sampleEntries = [
            FoodEntry(name: "Breakfast", calories: 350, protein: 18, carbs: 45, fat: 12),
            FoodEntry(name: "Lunch", calories: 600, protein: 30, carbs: 70, fat: 20),
            FoodEntry(name: "Dinner", calories: 800, protein: 40, carbs: 80, fat: 25)
        ]

        dailyNutrition = [
            DailyNutrition(date: yesterday, entries: sampleEntries),
            DailyNutrition(date: today, entries: [sampleEntries[0]])
        ]
    }
}