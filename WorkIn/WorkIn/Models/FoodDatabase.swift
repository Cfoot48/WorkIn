import Foundation

enum FoodCategory: String, CaseIterable {
    case proteins = "Proteins"
    case grains = "Grains"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case dairy = "Dairy"
    case nuts = "Nuts & Seeds"
    case beverages = "Beverages"
    case snacks = "Snacks"
    case fastFood = "Fast Food"
}

struct FoodTemplate: Identifiable {
    let id = UUID()
    let name: String
    let category: FoodCategory
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let servingSize: Double // in grams
    let servingDescription: String

    var caloriesPerServing: Double {
        (caloriesPer100g * servingSize) / 100
    }

    var proteinPerServing: Double {
        (proteinPer100g * servingSize) / 100
    }

    var carbsPerServing: Double {
        (carbsPer100g * servingSize) / 100
    }

    var fatPerServing: Double {
        (fatPer100g * servingSize) / 100
    }
}

class FoodDatabase: ObservableObject {
    static let shared = FoodDatabase()

    let foods: [FoodTemplate] = [
        // PROTEINS
        FoodTemplate(name: "Chicken Breast", category: .proteins, caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Salmon", category: .proteins, caloriesPer100g: 208, proteinPer100g: 22, carbsPer100g: 0, fatPer100g: 12, servingSize: 100, servingDescription: "3.5 oz fillet"),
        FoodTemplate(name: "Ground Turkey (93/7)", category: .proteins, caloriesPer100g: 120, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 2, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Eggs", category: .proteins, caloriesPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatPer100g: 11, servingSize: 50, servingDescription: "1 large egg"),
        FoodTemplate(name: "Greek Yogurt (Plain)", category: .proteins, caloriesPer100g: 59, proteinPer100g: 10, carbsPer100g: 3.6, fatPer100g: 0.4, servingSize: 170, servingDescription: "1 cup"),
        FoodTemplate(name: "Tuna (canned in water)", category: .proteins, caloriesPer100g: 116, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 0.8, servingSize: 85, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Lean Ground Beef (90/10)", category: .proteins, caloriesPer100g: 176, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 8, servingSize: 100, servingDescription: "3.5 oz"),
        FoodTemplate(name: "Tofu", category: .proteins, caloriesPer100g: 76, proteinPer100g: 8, carbsPer100g: 1.9, fatPer100g: 4.8, servingSize: 100, servingDescription: "1/2 cup"),
        FoodTemplate(name: "Shrimp", category: .proteins, caloriesPer100g: 85, proteinPer100g: 18, carbsPer100g: 0.2, fatPer100g: 0.5, servingSize: 85, servingDescription: "3 oz"),
        FoodTemplate(name: "Cottage Cheese", category: .proteins, caloriesPer100g: 98, proteinPer100g: 11, carbsPer100g: 3.4, fatPer100g: 4.3, servingSize: 113, servingDescription: "1/2 cup"),

        // GRAINS & CARBS
        FoodTemplate(name: "Brown Rice (cooked)", category: .grains, caloriesPer100g: 112, proteinPer100g: 2.6, carbsPer100g: 23, fatPer100g: 0.9, servingSize: 195, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Quinoa (cooked)", category: .grains, caloriesPer100g: 120, proteinPer100g: 4.4, carbsPer100g: 22, fatPer100g: 1.9, servingSize: 185, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Oatmeal (cooked)", category: .grains, caloriesPer100g: 68, proteinPer100g: 2.4, carbsPer100g: 12, fatPer100g: 1.4, servingSize: 234, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Sweet Potato", category: .grains, caloriesPer100g: 86, proteinPer100g: 1.6, carbsPer100g: 20, fatPer100g: 0.1, servingSize: 128, servingDescription: "1 medium"),
        FoodTemplate(name: "White Rice (cooked)", category: .grains, caloriesPer100g: 130, proteinPer100g: 2.7, carbsPer100g: 28, fatPer100g: 0.3, servingSize: 195, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "Whole Wheat Bread", category: .grains, caloriesPer100g: 247, proteinPer100g: 13, carbsPer100g: 41, fatPer100g: 4.2, servingSize: 28, servingDescription: "1 slice"),
        FoodTemplate(name: "Pasta (cooked)", category: .grains, caloriesPer100g: 131, proteinPer100g: 5, carbsPer100g: 25, fatPer100g: 1.1, servingSize: 140, servingDescription: "1 cup cooked"),
        FoodTemplate(name: "White Potato", category: .grains, caloriesPer100g: 77, proteinPer100g: 2, carbsPer100g: 17, fatPer100g: 0.1, servingSize: 148, servingDescription: "1 medium"),

        // VEGETABLES
        FoodTemplate(name: "Broccoli", category: .vegetables, caloriesPer100g: 34, proteinPer100g: 2.8, carbsPer100g: 7, fatPer100g: 0.4, servingSize: 91, servingDescription: "1 cup chopped"),
        FoodTemplate(name: "Spinach", category: .vegetables, caloriesPer100g: 23, proteinPer100g: 2.9, carbsPer100g: 3.6, fatPer100g: 0.4, servingSize: 30, servingDescription: "1 cup raw"),
        FoodTemplate(name: "Carrots", category: .vegetables, caloriesPer100g: 41, proteinPer100g: 0.9, carbsPer100g: 10, fatPer100g: 0.2, servingSize: 61, servingDescription: "1 medium"),
        FoodTemplate(name: "Bell Peppers", category: .vegetables, caloriesPer100g: 31, proteinPer100g: 1, carbsPer100g: 7, fatPer100g: 0.3, servingSize: 119, servingDescription: "1 medium"),
        FoodTemplate(name: "Asparagus", category: .vegetables, caloriesPer100g: 20, proteinPer100g: 2.2, carbsPer100g: 3.9, fatPer100g: 0.1, servingSize: 134, servingDescription: "1 cup"),
        FoodTemplate(name: "Cauliflower", category: .vegetables, caloriesPer100g: 25, proteinPer100g: 1.9, carbsPer100g: 5, fatPer100g: 0.3, servingSize: 100, servingDescription: "1 cup chopped"),
        FoodTemplate(name: "Green Beans", category: .vegetables, caloriesPer100g: 31, proteinPer100g: 1.8, carbsPer100g: 7, fatPer100g: 0.2, servingSize: 110, servingDescription: "1 cup"),
        FoodTemplate(name: "Cucumber", category: .vegetables, caloriesPer100g: 16, proteinPer100g: 0.7, carbsPer100g: 4, fatPer100g: 0.1, servingSize: 104, servingDescription: "1 cup sliced"),

        // FRUITS
        FoodTemplate(name: "Banana", category: .fruits, caloriesPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23, fatPer100g: 0.3, servingSize: 118, servingDescription: "1 medium"),
        FoodTemplate(name: "Apple", category: .fruits, caloriesPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14, fatPer100g: 0.2, servingSize: 182, servingDescription: "1 medium"),
        FoodTemplate(name: "Blueberries", category: .fruits, caloriesPer100g: 57, proteinPer100g: 0.7, carbsPer100g: 14, fatPer100g: 0.3, servingSize: 148, servingDescription: "1 cup"),
        FoodTemplate(name: "Strawberries", category: .fruits, caloriesPer100g: 32, proteinPer100g: 0.7, carbsPer100g: 8, fatPer100g: 0.3, servingSize: 152, servingDescription: "1 cup halves"),
        FoodTemplate(name: "Orange", category: .fruits, caloriesPer100g: 47, proteinPer100g: 0.9, carbsPer100g: 12, fatPer100g: 0.1, servingSize: 131, servingDescription: "1 medium"),
        FoodTemplate(name: "Grapes", category: .fruits, caloriesPer100g: 62, proteinPer100g: 0.6, carbsPer100g: 16, fatPer100g: 0.2, servingSize: 92, servingDescription: "1 cup"),

        // DAIRY
        FoodTemplate(name: "Milk (2%)", category: .dairy, caloriesPer100g: 50, proteinPer100g: 3.3, carbsPer100g: 4.7, fatPer100g: 2, servingSize: 244, servingDescription: "1 cup"),
        FoodTemplate(name: "Cheddar Cheese", category: .dairy, caloriesPer100g: 403, proteinPer100g: 25, carbsPer100g: 1.3, fatPer100g: 33, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Mozzarella Cheese", category: .dairy, caloriesPer100g: 300, proteinPer100g: 22, carbsPer100g: 2.2, fatPer100g: 22, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Butter", category: .dairy, caloriesPer100g: 717, proteinPer100g: 0.9, carbsPer100g: 0.1, fatPer100g: 81, servingSize: 14, servingDescription: "1 tbsp"),

        // NUTS & SEEDS
        FoodTemplate(name: "Almonds", category: .nuts, caloriesPer100g: 579, proteinPer100g: 21, carbsPer100g: 22, fatPer100g: 50, servingSize: 28, servingDescription: "1 oz (23 nuts)"),
        FoodTemplate(name: "Peanut Butter", category: .nuts, caloriesPer100g: 588, proteinPer100g: 25, carbsPer100g: 20, fatPer100g: 50, servingSize: 32, servingDescription: "2 tbsp"),
        FoodTemplate(name: "Walnuts", category: .nuts, caloriesPer100g: 654, proteinPer100g: 15, carbsPer100g: 14, fatPer100g: 65, servingSize: 28, servingDescription: "1 oz (14 halves)"),
        FoodTemplate(name: "Chia Seeds", category: .nuts, caloriesPer100g: 486, proteinPer100g: 17, carbsPer100g: 42, fatPer100g: 31, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Cashews", category: .nuts, caloriesPer100g: 553, proteinPer100g: 18, carbsPer100g: 30, fatPer100g: 44, servingSize: 28, servingDescription: "1 oz (18 nuts)"),

        // BEVERAGES
        FoodTemplate(name: "Orange Juice", category: .beverages, caloriesPer100g: 45, proteinPer100g: 0.7, carbsPer100g: 10, fatPer100g: 0.2, servingSize: 248, servingDescription: "1 cup"),
        FoodTemplate(name: "Coffee (black)", category: .beverages, caloriesPer100g: 2, proteinPer100g: 0.3, carbsPer100g: 0, fatPer100g: 0, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Green Tea", category: .beverages, caloriesPer100g: 1, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 0, servingSize: 240, servingDescription: "1 cup"),
        FoodTemplate(name: "Coca Cola", category: .beverages, caloriesPer100g: 42, proteinPer100g: 0, carbsPer100g: 11, fatPer100g: 0, servingSize: 355, servingDescription: "12 fl oz can"),

        // SNACKS
        FoodTemplate(name: "Dark Chocolate (70%)", category: .snacks, caloriesPer100g: 546, proteinPer100g: 8, carbsPer100g: 46, fatPer100g: 31, servingSize: 28, servingDescription: "1 oz"),
        FoodTemplate(name: "Granola Bar", category: .snacks, caloriesPer100g: 471, proteinPer100g: 10, carbsPer100g: 64, fatPer100g: 20, servingSize: 28, servingDescription: "1 bar"),
        FoodTemplate(name: "Popcorn (air-popped)", category: .snacks, caloriesPer100g: 387, proteinPer100g: 13, carbsPer100g: 78, fatPer100g: 4, servingSize: 8, servingDescription: "1 cup"),

        // FAST FOOD
        FoodTemplate(name: "McDonald's Big Mac", category: .fastFood, caloriesPer100g: 257, proteinPer100g: 12, carbsPer100g: 20, fatPer100g: 14, servingSize: 215, servingDescription: "1 sandwich"),
        FoodTemplate(name: "Pizza Slice (cheese)", category: .fastFood, caloriesPer100g: 266, proteinPer100g: 12, carbsPer100g: 33, fatPer100g: 10, servingSize: 107, servingDescription: "1 slice"),
        FoodTemplate(name: "French Fries (medium)", category: .fastFood, caloriesPer100g: 365, proteinPer100g: 4, carbsPer100g: 63, fatPer100g: 17, servingSize: 115, servingDescription: "medium order"),
    ]

    func searchFoods(query: String, category: FoodCategory? = nil) -> [FoodTemplate] {
        var filtered = foods

        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }

        if !query.isEmpty {
            filtered = filtered.filter { food in
                food.name.localizedCaseInsensitiveContains(query)
            }
        }

        return filtered.sorted { $0.name < $1.name }
    }

    func getFoodsByCategory(_ category: FoodCategory) -> [FoodTemplate] {
        foods.filter { $0.category == category }.sorted { $0.name < $1.name }
    }
}