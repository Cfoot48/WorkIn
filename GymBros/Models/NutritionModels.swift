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
    var food: Food
    var servings: Double
    var date: Date
    var meal: MealType

    var totalCalories: Double { food.caloriesPerServing * servings }
    var totalProtein: Double { food.proteinPerServing * servings }
    var totalCarbs: Double { food.carbsPerServing * servings }
    var totalFat: Double { food.fatPerServing * servings }

    init(food: Food, servings: Double, date: Date = Date(), meal: MealType) {
        self.id = UUID()
        self.food = food
        self.servings = servings
        self.date = date
        self.meal = meal
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
    @Published var foodEntries: [FoodEntry] = []
    @Published var nutritionGoals = NutritionGoals()
    @Published var foods: [Food] = []

    init() {
        loadSampleData()
    }

    func addFoodEntry(_ entry: FoodEntry) {
        foodEntries.append(entry)
    }

    func todaysEntries() -> [FoodEntry] {
        let calendar = Calendar.current
        return foodEntries.filter { calendar.isDateInToday($0.date) }
    }

    func todaysTotals() -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        let todaysEntries = self.todaysEntries()
        let calories = todaysEntries.reduce(0) { $0 + $1.totalCalories }
        let protein = todaysEntries.reduce(0) { $0 + $1.totalProtein }
        let carbs = todaysEntries.reduce(0) { $0 + $1.totalCarbs }
        let fat = todaysEntries.reduce(0) { $0 + $1.totalFat }
        return (calories, protein, carbs, fat)
    }

    private func loadSampleData() {
        foods = [
            Food(name: "Chicken Breast", caloriesPerServing: 231, proteinPerServing: 43.5, carbsPerServing: 0, fatPerServing: 5, servingSize: "100g"),
            Food(name: "Brown Rice", caloriesPerServing: 111, proteinPerServing: 2.6, carbsPerServing: 23, fatPerServing: 0.9, servingSize: "100g"),
            Food(name: "Broccoli", caloriesPerServing: 34, proteinPerServing: 2.8, carbsPerServing: 7, fatPerServing: 0.4, servingSize: "100g"),
            Food(name: "Banana", caloriesPerServing: 89, proteinPerServing: 1.1, carbsPerServing: 23, fatPerServing: 0.3, servingSize: "1 medium"),
            Food(name: "Greek Yogurt", caloriesPerServing: 59, proteinPerServing: 10, carbsPerServing: 3.6, fatPerServing: 0.4, servingSize: "100g")
        ]

        let sampleEntries = [
            FoodEntry(food: foods[0], servings: 1.5, date: Date(), meal: .lunch),
            FoodEntry(food: foods[1], servings: 1.0, date: Date(), meal: .lunch),
            FoodEntry(food: foods[3], servings: 1.0, date: Date(), meal: .breakfast)
        ]

        foodEntries.append(contentsOf: sampleEntries)
    }
}